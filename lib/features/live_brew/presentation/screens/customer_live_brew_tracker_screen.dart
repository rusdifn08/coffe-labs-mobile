import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/live_brew_v2_api_service.dart';
import '../../domain/live_brew_mirror_models.dart';
import '../controllers/live_brew_mirror_controller.dart';
import '../widgets/brewer_live_studio_tab.dart';
import '../widgets/business_seat_studio_tab.dart';
import '../widgets/live_brew_qr_scanner_modal.dart';
import 'live_brew_viewer_mirror_screen.dart';

/// Alias resmi LiveBrewHubScreen (Live Brewing 2.0 — Zero Simulation).
typedef LiveBrewHubScreen = CustomerLiveBrewTrackerScreen;

/// Hub Terpadu Live Brewing 2.0 (100% Real-Time, Zero Simulation):
/// - Tab 1 (`Siarkan`): Studio Barista / Home Brewer 1:1 Mirror + NTP Timer Sync
/// - Tab 2 (`Pindai`): Pindai QR Kamera / Input Kode 13-Digit atau `{cafe}/{meja}` -> Mirror 1:1 Viewer
/// - Tab 3 (`Studio Meja`): Kustomisasi Branding Kafe + Cetak Massal QR Meja/Kursi + POS Sync
class CustomerLiveBrewTrackerScreen extends ConsumerStatefulWidget {
  final String? addressCode;
  final String? cafeSlug;
  final String? seatSlug;
  final BrandedSeatResolution? initialResolution;

  const CustomerLiveBrewTrackerScreen({
    super.key,
    this.addressCode,
    this.cafeSlug,
    this.seatSlug,
    this.initialResolution,
  });

  @override
  ConsumerState<CustomerLiveBrewTrackerScreen> createState() =>
      _CustomerLiveBrewTrackerScreenState();
}

class _CustomerLiveBrewTrackerScreenState
    extends ConsumerState<CustomerLiveBrewTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _inputCtrl = TextEditingController();
  ParsedLiveBrewTarget? _activeTarget;
  String? _inputError;

  @override
  void initState() {
    super.initState();
    final initialTarget = _resolveInitialTarget();
    _activeTarget = initialTarget;
    if (initialTarget != null) {
      _inputCtrl.text = initialTarget.isBrandedSeat
          ? '${initialTarget.cafeSlug}/${initialTarget.seatSlug}'
          : (initialTarget.shareCode ?? '');
    }
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialTarget != null ? 1 : 0,
    );
  }

  ParsedLiveBrewTarget? _resolveInitialTarget() {
    final cafe = widget.cafeSlug?.trim();
    final seat = widget.seatSlug?.trim();
    if (cafe != null && cafe.isNotEmpty && seat != null && seat.isNotEmpty) {
      return ParsedLiveBrewTarget(
        cafeSlug: cafe.toLowerCase(),
        seatSlug: seat.toLowerCase(),
      );
    }
    final code = widget.addressCode?.trim();
    if (code != null && code.isNotEmpty) {
      final parsed = LiveBrewV2ApiService.parseUserInputOrUrl(code);
      return parsed.isValid ? parsed : null;
    }
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  void _openTargetFromRaw(String raw) {
    final parsed = LiveBrewV2ApiService.parseUserInputOrUrl(raw);
    if (!parsed.isValid) {
      setState(() {
        _inputError =
            'Masukkan kode 13 digit, slug kafe (mis. kopi-senja/meja-04), atau tempel link Live Brew.';
      });
      return;
    }
    setState(() {
      _inputError = null;
      _activeTarget = parsed;
      _inputCtrl.text = parsed.isBrandedSeat
          ? '${parsed.cafeSlug}/${parsed.seatSlug}'
          : (parsed.shareCode ?? '');
    });
  }

  Future<void> _scanQrCamera() async {
    final scanned = await LiveBrewQrScannerModal.scan(context);
    if (!mounted || scanned == null || scanned.trim().isEmpty) return;
    _openTargetFromRaw(scanned);
  }

  @override
  Widget build(BuildContext context) {
    final mirrorState = ref.watch(liveBrewMirrorProvider);
    final isLive = mirrorState.activeSession != null;

    return Scaffold(
      backgroundColor: const Color(0xFF12100E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12100E),
        foregroundColor: const Color(0xFFF9F5EE),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF9F5EE)),
        leading: Navigator.canPop(context)
            ? IconButton(
                tooltip: 'Kembali',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFF9F5EE),
                  size: 20,
                ),
              )
            : null,
        title: Row(
          children: [
            const Icon(
              Icons.qr_code_2_rounded,
              color: Color(0xFFD4A373),
              size: 21,
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Live Brewing 2.0',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFFF9F5EE),
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (isLive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ON AIR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1714),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFD4A373).withValues(alpha: 0.3),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFFD4A373),
                borderRadius: BorderRadius.circular(11),
              ),
              labelColor: const Color(0xFF12100E),
              unselectedLabelColor: const Color(0xFFF9F5EE),
              labelStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(height: 36, text: 'Siarkan'),
                Tab(height: 36, text: 'Pindai / Lacak'),
                Tab(height: 36, text: 'Studio Meja'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const BrewerLiveStudioTab(),
          _buildScanAndTrackTab(),
          BusinessSeatStudioTab(
            onStartBrewForSeat: (seat) {
              ref
                  .read(liveBrewMirrorProvider.notifier)
                  .selectSeatForBroadcast(seat.id);
              _tabController.animateTo(0);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Meja ${seat.seatLabel} dipilih — siap mulai siaran Live Brew!',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScanAndTrackTab() {
    if (_activeTarget != null) {
      return LiveBrewViewerMirrorScreen(
        target: _activeTarget!,
        initialResolution: widget.initialResolution,
        onClose: () => setState(() => _activeTarget = null),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1714),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFD4A373).withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A373).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Color(0xFFD4A373),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lacak Seduhan Barista 1:1',
                          style: TextStyle(
                            color: Color(0xFFF9F5EE),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pindai QR meja/kursi kafe atau masukkan kode siaran nyata dari barista.',
                          style: TextStyle(
                            color: Color(0xFFCBBFB2),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A373),
                    foregroundColor: const Color(0xFF12100E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _scanQrCamera,
                  icon: const Icon(Icons.camera_alt_rounded, size: 19),
                  label: const Text(
                    'Pindai QR dengan Kamera',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Atau Masukkan Kode / Link Live Brew',
                style: TextStyle(
                  color: Color(0xFFF9F5EE),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _inputCtrl,
                style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
                onSubmitted: _openTargetFromRaw,
                decoration: InputDecoration(
                  hintText: 'Contoh: 7123456789012 atau kopi-senja/meja-04',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9C8F82),
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF12100E),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(
                      color: const Color(0xFFD4A373).withValues(alpha: 0.35),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(
                      color: Color(0xFFD4A373),
                      width: 1.5,
                    ),
                  ),
                  errorText: _inputError,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF9F5EE),
                    side: const BorderSide(color: Color(0xFFD4A373)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  onPressed: () => _openTargetFromRaw(_inputCtrl.text),
                  icon: const Icon(CupertinoIcons.arrow_right_circle_fill, size: 17),
                  label: const Text(
                    'Hubungkan ke Live Mirror',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1714),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Format Alamat yang Didukung (100% Real-Time)',
                style: TextStyle(
                  color: Color(0xFFD4A373),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Link Kafe Bisnis: https://coffeelabs.com/livebrew/{kafe}/{meja}\n'
                '• Slug Cepat: kopi-senja/meja-04 atau kopi-senja/kursi-bar-02\n'
                '• Kode 13 Digit Sesi Personal / Meja: 7xxxxxxxxxxxx / 8xxxxxxxxxxxx',
                style: TextStyle(
                  color: Color(0xFFCBBFB2),
                  fontSize: 11.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
