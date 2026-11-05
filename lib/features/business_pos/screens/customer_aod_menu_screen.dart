import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/business_pos_models.dart';
import '../../../providers/aod_display_engine_provider.dart';
import '../../../providers/workspace_mode_provider.dart';
import '../../../services/business_pos_api_service.dart';
import '../presentation/controllers/aod_kiosk_controller.dart';
import '../widgets/business_menu_asset_image.dart';
import 'oled_diagnostic_screen.dart';

class CustomerAodMenuScreen extends ConsumerStatefulWidget {
  final BusinessStoreConfig config;
  final List<BusinessMenuItem>? initialMenuItems;

  const CustomerAodMenuScreen({
    super.key,
    required this.config,
    this.initialMenuItems,
  });

  @override
  ConsumerState<CustomerAodMenuScreen> createState() => _CustomerAodMenuScreenState();
}

class _CustomerAodMenuScreenState extends ConsumerState<CustomerAodMenuScreen> {
  List<BusinessMenuItem> _menuItems = [];
  bool _isLoading = true;
  int _currentPage = 0;
  Timer? _carouselTimer;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (widget.initialMenuItems != null && widget.initialMenuItems!.isNotEmpty) {
      _menuItems = widget.initialMenuItems!
          .where((item) => item.showInAod && item.isAvailable)
          .toList();
      _isLoading = false;
    }

    _loadMenu();
    _startAutoCarouselTimer();

    // Aktifkan Hardware Kiosk & Auto Dimming Engine
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aodDisplayEngineProvider.notifier).activateEngine(
            activeBrightness: widget.config.aodActiveBrightness,
            idleBrightness: widget.config.aodIdleBrightness,
            enablePixelShift: widget.config.pixelShiftEnabled,
          );
    });
  }

  void _startAutoCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      if (!mounted) return;
      final columns = widget.config.aodGridColumns.clamp(1, 8);
      final rows = widget.config.aodGridRows.clamp(1, 6);
      final itemsPerPage = columns * rows;
      if (_menuItems.isEmpty) return;
      final totalPages = (_menuItems.length / itemsPerPage).ceil();

      if (totalPages > 1 && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % totalPages;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _restartAutoCarouselTimer() {
    _startAutoCarouselTimer();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu() async {
    final items = await BusinessPosApiService.fetchMenuList();
    if (mounted) {
      setState(() {
        // Bedakan menu jualan kasir dengan menu pajangan display AOD
        _menuItems = items.where((item) => item.showInAod && item.isAvailable).toList();
        _isLoading = false;
      });
    }
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _VerifyCashierPinModal(
        onSuccess: () async {
          Navigator.pop(ctx);
          // Matikan Hardware Kiosk & AOD engine & kembalikan ke Mode Kasir
          await ref.read(aodKioskControllerProvider.notifier).unlockKiosk('1234');
          await ref.read(aodDisplayEngineProvider.notifier).deactivateEngine();
          if (mounted) {
            ref.read(workspaceModeProvider.notifier).forceSetMode(WorkspaceMode.businessCashier);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aodState = ref.watch(aodDisplayEngineProvider);
    final kioskState = ref.watch(aodKioskControllerProvider);
    final effectiveOffset = kioskState.isKioskLocked
        ? kioskState.pixelShiftOffset
        : aodState.pixelShiftOffset;

    final columns = widget.config.aodGridColumns.clamp(1, 8);
    final rows = widget.config.aodGridRows.clamp(1, 6);
    final itemsPerPage = columns * rows;

    return PopScope(
      canPop: false, // Pelanggan tidak bisa keluar dengan gesture back Android
      child: Scaffold(
        backgroundColor: Colors.black, // #000000 True Pitch-Black OLED
        body: Listener(
          onPointerDown: (_) {
            _restartAutoCarouselTimer();
            ref.read(aodDisplayEngineProvider.notifier).onUserInteraction(
                  activeBrightness: widget.config.aodActiveBrightness,
                  idleBrightness: widget.config.aodIdleBrightness,
                );
            ref.read(aodKioskControllerProvider.notifier).onUserInteraction(
                  activeBrightness: widget.config.aodActiveBrightness,
                  idleBrightness: widget.config.aodIdleBrightness,
                );
          },
          child: Stack(
            children: [
              // 1. Matriks Grid Menu dengan OLED Pixel-Shifting (Anti Burn-In)
              Transform.translate(
                offset: effectiveOffset,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        // Store Bar Branding Header
                        _buildOledHeader(),
                        const SizedBox(height: 10),

                        // Grid Viewport Lock (LayoutBuilder)
                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CupertinoActivityIndicator(color: Color(0xFFD4AF37)),
                                )
                              : _menuItems.isEmpty
                                  ? Center(
                                      child: Container(
                                        constraints: const BoxConstraints(maxWidth: 420),
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F0F0F),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: const Color(0xFF262626)),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(CupertinoIcons.tv, color: Color(0xFFD4AF37), size: 36),
                                            ),
                                            const SizedBox(height: 14),
                                            const Text(
                                              'Belum Ada Menu di Pajangan AOD',
                                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Menu kasir sengaja dipisahkan dari pajangan etalase bar pelanggan agar tampilan tablet selalu rapi.\n\nUntuk memunculkan menu di layar ini:\n1. Buka Mode Kasir (Gunakan PIN default: 1234)\n2. Buka tombol Kelola Menu\n3. Nyalakan switch "Tayang di AOD"',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.45),
                                            ),
                                            const SizedBox(height: 18),
                                            ElevatedButton.icon(
                                              onPressed: _showPinDialog,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFD4AF37),
                                                foregroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              icon: const Icon(CupertinoIcons.lock_shield, size: 16),
                                              label: const Text('Buka Kasir untuk Mengatur (PIN: 1234)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : LayoutBuilder(
                                      builder: (context, constraints) {
                                        final totalPages = (_menuItems.length / itemsPerPage).ceil();

                                        return Column(
                                          children: [
                                            Expanded(
                                              child: PageView.builder(
                                                controller: _pageController,
                                                itemCount: totalPages,
                                                onPageChanged: (page) => setState(() => _currentPage = page),
                                                itemBuilder: (ctx, pageIndex) {
                                                  final startIndex = pageIndex * itemsPerPage;
                                                  final endIndex = (startIndex + itemsPerPage).clamp(0, _menuItems.length);
                                                  final pageItems = _menuItems.sublist(startIndex, endIndex);

                                                  final cardWidth = (constraints.maxWidth - ((columns - 1) * 12)) / columns;
                                                  final availableHeight = constraints.maxHeight - (totalPages > 1 ? 24 : 0);
                                                  final cardHeight = (availableHeight - ((rows - 1) * 12)) / rows;

                                                  return Wrap(
                                                    spacing: 12,
                                                    runSpacing: 12,
                                                    children: pageItems.map((item) {
                                                      return SizedBox(
                                                        width: cardWidth,
                                                        height: cardHeight,
                                                        child: _AodMenuCard(
                                                          item: item,
                                                          borderColor: widget.config.aodCardBorderColor,
                                                          accentColor: widget.config.aodAccentColor,
                                                        ),
                                                      );
                                                    }).toList(),
                                                  );
                                                },
                                              ),
                                            ),
                                            if (totalPages > 1) ...[
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'HALAMAN ${_currentPage + 1}/$totalPages  ',
                                                    style: const TextStyle(
                                                      color: Colors.white38,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1.0,
                                                    ),
                                                  ),
                                                  ...List.generate(totalPages, (index) {
                                                    final isCurrent = index == _currentPage;
                                                    return AnimatedContainer(
                                                      duration: const Duration(milliseconds: 300),
                                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                                      width: isCurrent ? 18 : 6,
                                                      height: 5,
                                                      decoration: BoxDecoration(
                                                        color: isCurrent ? const Color(0xFFD4AF37) : Colors.white24,
                                                        borderRadius: BorderRadius.circular(3),
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ],
                                          ],
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Hidden Cashier Exit Lock Icon (Pojok Kanan Atas: 60x60dp invisible target, onLongPress only)
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: _showPinDialog,
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.all(12),
                      color: Colors.transparent, // Tak kasat mata oleh pelanggan
                      child: const Icon(
                        CupertinoIcons.lock_shield,
                        color: Color(0x18FFFFFF), // Nyaris transparan (< 10% opacity)
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOledHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
              widget.config.storeName.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFEAEAEA),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // OLED Health & Diagnostic Pill
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OledDiagnosticScreen()),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF262626)),
                ),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.waveform_path_ecg, color: Color(0xFFD4AF37), size: 12),
                    SizedBox(width: 5),
                    Text(
                      'OLED Diagnostic',
                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF262626)),
              ),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.sparkles, color: Color(0xFFD4AF37), size: 12),
                  SizedBox(width: 4),
                  Text(
                    'ARTISAN SELECTION',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AodMenuCard extends StatelessWidget {
  final BusinessMenuItem item;
  final String borderColor;
  final String accentColor;

  const _AodMenuCard({
    required this.item,
    required this.borderColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // #000000 True Black OLED
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF242424), // 1.0px Ultra-crisp outlined
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Visual Floating Cutout (55% Height)
          Expanded(
            flex: 55,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: BusinessMenuAssetImage(
                  assetUrl: item.assetUrl,
                  assetFormat: item.assetFormat,
                  fit: BoxFit.contain,
                  fallbackIconColor: const Color(0xFFD4AF37),
                  fallbackIconSize: 42,
                ),
              ),
            ),
          ),

          // Detail Info (45% Height - Centered Card Design)
          Expanded(
            flex: 45,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFEAEAEA),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.description.isNotEmpty ? item.description : 'Artisan Crafted Beverage',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8E8E8E),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        item.formattedPrice,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFD4AF37), // Warm Gold Price
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF262626)),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF8E8E8E),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyCashierPinModal extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const _VerifyCashierPinModal({required this.onSuccess});

  @override
  ConsumerState<_VerifyCashierPinModal> createState() => _VerifyCashierPinModalState();
}

class _VerifyCashierPinModalState extends ConsumerState<_VerifyCashierPinModal> {
  String _pin = '';
  bool _isChecking = false;
  String? _errorMessage;

  void _onDigit(String d) {
    if (_pin.length < 8) {
      setState(() {
        _pin += d;
        _errorMessage = null;
      });
      if (_pin.length >= 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isChecking = true);

    // 1. Coba verifikasi offline native via KioskDirectBootStore (Argon2 / SHA-256)
    final unlocked = await ref.read(aodKioskControllerProvider.notifier).unlockKiosk(_pin);
    if (unlocked) {
      if (mounted) {
        setState(() => _isChecking = false);
        widget.onSuccess();
      }
      return;
    }

    // 2. Fallback verifikasi online ke backend jika koneksi tersedia
    final ok = await BusinessPosApiService.verifyCashierPin(_pin);
    if (ok) {
      await ref.read(aodKioskControllerProvider.notifier).unlockKiosk(_pin);
      if (mounted) {
        setState(() => _isChecking = false);
        widget.onSuccess();
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isChecking = false;
        _errorMessage = 'PIN Salah (Coba PIN default: 1234)';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.lock_shield_fill, color: Color(0xFFD4AF37), size: 36),
            const SizedBox(height: 10),
            const Text(
              'Keluar dari Mode Display',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              'Masukkan PIN Kasir Barista (Default: 1234)',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // PIN Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: filled ? const Color(0xFFD4AF37) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                  ),
                );
              }),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],

            const SizedBox(height: 20),

            // Numeric Keypad
            _buildNumpad(),

            const SizedBox(height: 14),

            // Tombol Pintas PIN Default
            InkWell(
              onTap: _isChecking
                  ? null
                  : () {
                      setState(() => _pin = '1234');
                      _verifyPin();
                    },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.bolt_fill, size: 14, color: Color(0xFFD4AF37)),
                    SizedBox(width: 6),
                    Text(
                      'Buka Cepat (PIN Default: 1234)',
                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'del'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 60, height: 50);
              if (key == 'del') {
                return IconButton(
                  icon: const Icon(CupertinoIcons.delete_left_fill, color: Colors.white70),
                  onPressed: _onBackspace,
                );
              }
              return InkWell(
                onTap: _isChecking ? null : () => _onDigit(key),
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  width: 60,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    key,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
