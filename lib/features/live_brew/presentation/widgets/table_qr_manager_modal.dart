import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/utils/external_url_launcher.dart';
import '../../../../theme/app_theme.dart';
import '../../data/live_brew_v2_api_service.dart';
import '../controllers/live_brew_mirror_controller.dart';
import '../screens/customer_live_brew_tracker_screen.dart';
import '../services/live_brew_qr_card_exporter.dart';

/// Bright Coffee Labs Live Brew 2.0 Quick Broadcast & QR Modal launched
/// directly from `BrewTimerScreen` (Menu ☰ -> Live Brew).
///
/// Unified 100% with `liveBrewMirrorProvider` (/api/v1/livebrew/v2/sessions)
/// so the generated QR & live web URL (`https://brewingcoffee.vercel.app/livebrew/...`)
/// opens immediately in any mobile browser or in-app mirror with 1:1 NTP timer sync.
class TableQrManagerModal extends ConsumerStatefulWidget {
  final Map<String, dynamic>? activeRecipe;
  final double Function()? weightSampler;
  final bool isTimerRunning;
  final int elapsedSeconds;
  final int activeStepIndex;
  final int waterTempCelsius;

  const TableQrManagerModal({
    super.key,
    this.activeRecipe,
    this.weightSampler,
    this.isTimerRunning = false,
    this.elapsedSeconds = 0,
    this.activeStepIndex = 0,
    this.waterTempCelsius = 92,
  });

  static Future<void> show(
    BuildContext context, {
    Map<String, dynamic>? activeRecipe,
    double Function()? weightSampler,
    bool isTimerRunning = false,
    int elapsedSeconds = 0,
    int activeStepIndex = 0,
    int waterTempCelsius = 92,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TableQrManagerModal(
        activeRecipe: activeRecipe,
        weightSampler: weightSampler,
        isTimerRunning: isTimerRunning,
        elapsedSeconds: elapsedSeconds,
        activeStepIndex: activeStepIndex,
        waterTempCelsius: waterTempCelsius,
      ),
    );
  }

  @override
  ConsumerState<TableQrManagerModal> createState() => _TableQrManagerModalState();
}

class _TableQrManagerModalState extends ConsumerState<TableQrManagerModal> {
  final TextEditingController _customerCtrl =
      TextEditingController(text: 'Tamu Slow Bar');
  bool _sharingQrImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(liveBrewMirrorProvider.notifier).loadBusinessStudio();
    });
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    super.dispose();
  }

  Future<void> _startLiveBrewNow(LiveBrewMirrorController ctrl) async {
    final recipe = widget.activeRecipe;
    final method = (recipe?['method'] ?? 'V60').toString();
    final recipeTitle = (recipe?['title'] ?? 'Manual Brew').toString();
    final beanName = (recipe?['beanName'] ?? '').toString().trim();
    final beanSnapshot = beanName.isNotEmpty
        ? <String, dynamic>{
            'name': beanName,
            'roastery': (recipe?['roaster'] ?? 'Coffee Labs Slow Bar').toString(),
          }
        : null;

    await ctrl.startRealSession(
      customerName: _customerCtrl.text.trim().isEmpty
          ? 'Tamu Coffee Labs'
          : _customerCtrl.text.trim(),
      methodId: method.toLowerCase().replaceAll(' ', '_'),
      methodName: method,
      recipeTitle: recipe != null ? recipeTitle : null,
      recipeSnapshot: recipe,
      beanSnapshot: beanSnapshot,
      initialTimerRunning: widget.isTimerRunning,
      initialElapsedMs: widget.elapsedSeconds * 1000,
      initialStepIndex: widget.activeStepIndex,
      initialTempC: widget.waterTempCelsius.toDouble(),
      initialWeightG: widget.weightSampler?.call() ?? 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveBrewMirrorProvider);
    final ctrl = ref.read(liveBrewMirrorProvider.notifier);
    final session = state.activeSession;
    final isBroadcasting = session != null;

    final selectedSeat = state.seats
        .where((s) => s.id == state.selectedSeatId)
        .firstOrNull;

    final String? activeUrl = session != null
        ? LiveBrewV2ApiService.normalizePublicShareUrl(session.shareUrl)
        : (selectedSeat != null
            ? LiveBrewV2ApiService.normalizePublicShareUrl(selectedSeat.brandedUrl)
            : null);
    final String? activeCode = session?.shareCode ?? selectedSeat?.numericFallbackCode;

    final recipeTitle = (widget.activeRecipe?['title'] ?? '').toString().trim();
    final recipeMethod = (widget.activeRecipe?['method'] ?? '').toString().trim();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppTheme.borderWarm,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: (isBroadcasting
                            ? const Color(0xFFDC2626)
                            : AppTheme.primaryBrown)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isBroadcasting
                        ? Icons.sensors_rounded
                        : Icons.qr_code_2_rounded,
                    color: isBroadcasting
                        ? const Color(0xFFDC2626)
                        : AppTheme.primaryBrown,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Brew & Bagikan QR',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        isBroadcasting
                            ? '${session.activeViewersCount} menonton • ${session.cheersCount} apresiasi'
                            : 'Siarkan seduhan 1:1 secara langsung ke pelanggan',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isBroadcasting)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LIVE 1:1',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Active Recipe Pill
            if (recipeTitle.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.drop_fill,
                      size: 16,
                      color: AppTheme.primaryBrown,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recipeMethod.isNotEmpty
                            ? '$recipeMethod • $recipeTitle'
                            : recipeTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Friendly error notice (zero raw DioException!)
            if (state.broadcastError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
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
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.broadcastError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF991B1B),
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // QR Card when Active Session or Selected Seat Exists
            if (activeUrl != null && activeCode != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isBroadcasting
                        ? const Color(0xFF16A34A).withValues(alpha: 0.5)
                        : AppTheme.borderWarm,
                    width: isBroadcasting ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: QrImageView(
                        data: activeUrl,
                        version: QrVersions.auto,
                        size: 168,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCream,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        activeUrl,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: activeUrl));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Link Live Brew berhasil disalin!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryBrown,
                              side: const BorderSide(color: AppTheme.borderWarm),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 15),
                            label: const Text(
                              'Salin Link',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _sharingQrImage
                                ? null
                                : () async {
                                    setState(() => _sharingQrImage = true);
                                    final rec = widget.activeRecipe ??
                                        session?.recipeSnapshot;
                                    final dose = rec?['coffeeWeightGrams'];
                                    final water = rec?['totalWaterWeightGrams'];
                                    final temp = rec?['waterTempCelsius'] ??
                                        widget.waterTempCelsius;
                                    final specLine = (dose != null && water != null)
                                        ? '${dose}g : ${water}ml · $temp°C'
                                        : null;
                                    await LiveBrewQrCardExporter
                                        .shareQrCardWithCaption(
                                      liveUrl: activeUrl,
                                      title: recipeTitle.isNotEmpty
                                          ? recipeTitle
                                          : (session?.selectedRecipeTitle ??
                                              'Coffee Labs Live Brew'),
                                      subtitle: recipeMethod.isNotEmpty
                                          ? recipeMethod
                                          : session?.selectedMethodName,
                                      baristaName: session?.brewerDisplayName,
                                      specLine: specLine,
                                      seatLabel: selectedSeat?.seatLabel,
                                    );
                                    if (mounted) {
                                      setState(() => _sharingQrImage = false);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            icon: _sharingQrImage
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.qr_code_2_rounded, size: 16),
                            label: const Text(
                              'Kirim QR (WA)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              launchExternalUri(Uri.parse(activeUrl));
                            },
                            icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                            label: const Text(
                              'Buka di Browser',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CustomerLiveBrewTrackerScreen(
                                    addressCode: activeUrl,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility_rounded, size: 16),
                            label: const Text(
                              'Pratinjau Live',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Pre-Broadcast Options (Customer Name + Business Seat Selector)
            if (!isBroadcasting) ...[
              TextField(
                controller: _customerCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Pelanggan / Tamu',
                  labelStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: AppTheme.borderWarm),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: AppTheme.borderWarm),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: AppTheme.primaryBrown),
                  ),
                ),
              ),
              if (state.isBusinessUser && state.seats.isNotEmpty) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  initialValue: state.selectedSeatId,
                  decoration: InputDecoration(
                    labelText: 'Pilih Meja / Kursi Kafe (Opsional)',
                    labelStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: AppTheme.borderWarm),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: AppTheme.borderWarm),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Sesi Personal / Takeaway (QR Dinamis)'),
                    ),
                    ...state.seats.map(
                      (s) => DropdownMenuItem<String?>(
                        value: s.id,
                        child: Text('${s.seatLabel} • ${s.zoneArea}'),
                      ),
                    ),
                  ],
                  onChanged: ctrl.selectSeatForBroadcast,
                ),
              ],
              const SizedBox(height: 14),
            ],

            // Primary Start / Stop Broadcast Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBroadcasting
                      ? const Color(0xFFDC2626)
                      : AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: state.isStartingSession
                    ? null
                    : () async {
                        if (isBroadcasting) {
                          await ctrl.stopBroadcast();
                        } else {
                          await _startLiveBrewNow(ctrl);
                        }
                      },
                icon: state.isStartingSession
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isBroadcasting
                            ? Icons.stop_circle_rounded
                            : Icons.sensors_rounded,
                        size: 20,
                      ),
                label: Text(
                  isBroadcasting
                      ? 'Hentikan Siaran Live Brew'
                      : 'Mulai Siaran Live & Buat QR',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LiveBrewHubScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.dashboard_customize_rounded, size: 17),
                label: const Text(
                  'Buka Live Brewing 2.0 Hub & Studio Meja',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
