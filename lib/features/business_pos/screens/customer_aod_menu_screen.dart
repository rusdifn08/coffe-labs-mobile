import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/business_pos_models.dart';
import '../../../providers/aod_display_engine_provider.dart';
import '../../../providers/workspace_mode_provider.dart';
import '../../../services/business_pos_api_service.dart';

class CustomerAodMenuScreen extends ConsumerStatefulWidget {
  final BusinessStoreConfig config;

  const CustomerAodMenuScreen({
    super.key,
    required this.config,
  });

  @override
  ConsumerState<CustomerAodMenuScreen> createState() => _CustomerAodMenuScreenState();
}

class _CustomerAodMenuScreenState extends ConsumerState<CustomerAodMenuScreen> {
  List<BusinessMenuItem> _menuItems = [];
  bool _isLoading = true;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadMenu();

    // Aktifkan Hardware Kiosk & Auto Dimming Engine
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aodDisplayEngineProvider.notifier).activateEngine(
            activeBrightness: widget.config.aodActiveBrightness,
            idleBrightness: widget.config.aodIdleBrightness,
            enablePixelShift: widget.config.pixelShiftEnabled,
          );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadMenu() async {
    final items = await BusinessPosApiService.fetchMenuList();
    if (mounted) {
      setState(() {
        _menuItems = items;
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
          // Matikan AOD engine & kembalikan ke Mode Kasir
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
    final columns = widget.config.aodGridColumns.clamp(1, 8);
    final rows = widget.config.aodGridRows.clamp(1, 6);
    final itemsPerPage = columns * rows;

    return PopScope(
      canPop: false, // Pelanggan tidak bisa keluar dengan gesture back Android
      child: Scaffold(
        backgroundColor: Colors.black, // #000000 True Pitch-Black OLED
        body: Listener(
          onPointerDown: (_) {
            ref.read(aodDisplayEngineProvider.notifier).onUserInteraction(
                  activeBrightness: widget.config.aodActiveBrightness,
                  idleBrightness: widget.config.aodIdleBrightness,
                );
          },
          child: Stack(
            children: [
              // 1. Matriks Grid Menu dengan OLED Pixel-Shifting (Anti Burn-In)
              Transform.translate(
                offset: aodState.pixelShiftOffset,
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
                                  ? const Center(
                                      child: Text(
                                        'Belum ada menu yang diatur.',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    )
                                  : LayoutBuilder(
                                      builder: (context, constraints) {
                                        final totalPages = (_menuItems.length / itemsPerPage).ceil();

                                        return PageView.builder(
                                          controller: _pageController,
                                          itemCount: totalPages,
                                          itemBuilder: (ctx, pageIndex) {
                                            final startIndex = pageIndex * itemsPerPage;
                                            final endIndex = (startIndex + itemsPerPage).clamp(0, _menuItems.length);
                                            final pageItems = _menuItems.sublist(startIndex, endIndex);

                                            final cardWidth = (constraints.maxWidth - ((columns - 1) * 12)) / columns;
                                            final cardHeight = (constraints.maxHeight - ((rows - 1) * 12)) / rows;

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
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Hidden Cashier Exit Lock Icon (Pojok Kanan Atas)
              Positioned(
                top: 10,
                right: 12,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: _showPinDialog,
                    onLongPress: _showPinDialog,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.lock_shield,
                        color: Color(0x33FFFFFF), // Nyaris transparan agar tidak menarik perhatian pelanggan
                        size: 20,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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
                'ARTISAN COFFEE SELECTION',
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
                child: item.assetFormat == 'SVG'
                    ? SvgPicture.network(
                        item.assetUrl,
                        fit: BoxFit.contain,
                        placeholderBuilder: (context) => const CupertinoActivityIndicator(color: Colors.white24),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.assetUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const CupertinoActivityIndicator(color: Colors.white24),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.local_cafe,
                          color: Color(0xFFD4AF37),
                          size: 40,
                        ),
                      ),
              ),
            ),
          ),

          // Detail Info (45% Height)
          Expanded(
            flex: 45,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFEAEAEA),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8E8E8E),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.formattedPrice,
                        style: const TextStyle(
                          color: Color(0xFFD4AF37), // Warm Gold Price
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF262626)),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF7A7A7A),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
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

class _VerifyCashierPinModal extends StatefulWidget {
  final VoidCallback onSuccess;

  const _VerifyCashierPinModal({required this.onSuccess});

  @override
  State<_VerifyCashierPinModal> createState() => _VerifyCashierPinModalState();
}

class _VerifyCashierPinModalState extends State<_VerifyCashierPinModal> {
  String _pin = '';
  bool _isChecking = false;
  String? _errorMessage;

  void _onDigit(String d) {
    if (_pin.length < 6) {
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
    final ok = await BusinessPosApiService.verifyCashierPin(_pin);
    setState(() => _isChecking = false);

    if (ok) {
      widget.onSuccess();
    } else {
      setState(() {
        _errorMessage = 'PIN Salah';
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
              'Masukkan PIN Kasir Barista',
              style: TextStyle(color: Colors.white54, fontSize: 12),
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

            const SizedBox(height: 10),
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
