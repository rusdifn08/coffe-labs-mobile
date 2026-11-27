import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../data/live_brew_v2_api_service.dart';
import '../../domain/live_brew_mirror_models.dart';
import '../controllers/live_brew_mirror_controller.dart';
import '../widgets/brewer_live_studio_tab.dart';
import '../widgets/business_seat_studio_tab.dart';
import '../widgets/live_brew_qr_scanner_modal.dart';
import 'live_brew_viewer_mirror_screen.dart';

/// Alias resmi LiveBrewHubScreen (Live Brewing 2.0 — Bright Specialty UI).
typedef LiveBrewHubScreen = CustomerLiveBrewTrackerScreen;

/// Hub Terpadu Live Brewing 2.0 (100% Real-Time, Bright Coffee Labs UI):
/// - Tab 1 (`Siarkan`): Studio Barista / Home Brewer 1:1 Mirror + NTP Timer Sync
/// - Tab 2 (`Pindai / Lacak`): Pindai QR Kamera / Input Kode 13-Digit atau `{cafe}/{meja}`
/// - Tab 3 (`Studio Meja`): Kustomisasi Branding Kafe + Tambah/Generate Massal QR Meja & Cetak
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
            'Masukkan kode 13 digit, slug kafe (mis. kopi-senja/meja-01), atau tempel link Live Brew.';
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
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        foregroundColor: AppTheme.textDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        leading: Navigator.canPop(context)
            ? IconButton(
                tooltip: 'Kembali',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textDark,
                  size: 20,
                ),
              )
            : null,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: AppTheme.primaryBrown,
                size: 18,
              ),
            ),
            const SizedBox(width: 9),
            const Flexible(
              child: Text(
                'Live Brewing 2.0',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textDark,
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
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderWarm),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppTheme.primaryBrown,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textMuted,
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
                  behavior: SnackBarBehavior.floating,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppTheme.primaryBrown,
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
                            color: AppTheme.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pindai QR meja/kursi kafe atau masukkan kode siaran langsung dari barista.',
                          style: TextStyle(
                            color: AppTheme.textMuted,
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
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Atau Masukkan Kode / Link Live Brew',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _inputCtrl,
                style: const TextStyle(color: AppTheme.textDark, fontSize: 13),
                onSubmitted: _openTargetFromRaw,
                decoration: InputDecoration(
                  hintText: 'Contoh: 3123456789012 atau kopi-senja/meja-01',
                  hintStyle: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: AppTheme.bgCream,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: AppTheme.borderWarm),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBrown,
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
                    foregroundColor: AppTheme.primaryBrown,
                    side: const BorderSide(color: AppTheme.primaryBrown),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.borderWarm),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Format Alamat yang Didukung (100% Real-Time)',
                style: TextStyle(
                  color: AppTheme.primaryBrown,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Link Web Live: https://brewingcoffee.vercel.app/livebrew/{kode}\n'
                '• Link Kafe Bisnis: https://brewingcoffee.vercel.app/livebrew/{kafe}/{meja}\n'
                '• Slug Cepat: kopi-senja/meja-01 atau kopi-senja/kursi-bar-02',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11.5,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
