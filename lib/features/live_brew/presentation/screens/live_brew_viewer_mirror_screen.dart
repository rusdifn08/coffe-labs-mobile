import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../data/live_brew_v2_api_service.dart';
import '../../domain/live_brew_mirror_models.dart';
import '../../domain/services/ntp_synced_timer_engine.dart';
import '../widgets/mirrored_circular_timer_card.dart';

/// Layar Mirror 1:1 Penonton / Pelanggan untuk Live Brewing 2.0 (Zero Simulation).
/// Mendukung resolusi 13-digit Share Code maupun Branded Cafe Seat Slug (`/{cafe}/{seat}`).
class LiveBrewViewerMirrorScreen extends ConsumerStatefulWidget {
  final ParsedLiveBrewTarget target;
  final BrandedSeatResolution? initialResolution;
  final VoidCallback? onClose;

  const LiveBrewViewerMirrorScreen({
    super.key,
    required this.target,
    this.initialResolution,
    this.onClose,
  });

  @override
  ConsumerState<LiveBrewViewerMirrorScreen> createState() =>
      _LiveBrewViewerMirrorScreenState();
}

class _LiveBrewViewerMirrorScreenState
    extends ConsumerState<LiveBrewViewerMirrorScreen> {
  final NtpSyncedTimerEngine _timerEngine = NtpSyncedTimerEngine();
  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;
  Timer? _reconnectTimer;

  BrandedSeatResolution? _resolution;
  LiveSessionMirrorSnapshot? _snapshot;
  bool _loading = true;
  bool _wsConnected = false;
  bool _sendingCheer = false;
  int _localCheers = 0;
  String? _errorMessage;

  bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    if (widget.initialResolution != null) {
      _applyResolution(widget.initialResolution!);
      _loading = false;
    } else {
      Future.microtask(_resolveAndConnect);
    }
  }

  @override
  void didUpdateWidget(covariant LiveBrewViewerMirrorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target.streamTargetKey != widget.target.streamTargetKey) {
      _closeSocket();
      _timerEngine.reset();
      _resolution = null;
      _snapshot = null;
      _errorMessage = null;
      Future.microtask(_resolveAndConnect);
    }
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _closeSocket();
    _timerEngine.dispose();
    super.dispose();
  }

  Future<void> _resolveAndConnect() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final api = ref.read(liveBrewV2ApiProvider);
    try {
      await _calibrateNtp(api);
      final res = await api.resolveTarget(widget.target);
      if (!mounted) return;
      _applyResolution(res);
      setState(() => _loading = false);
      await _connectViewerWs(api);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage =
            'Kode atau meja Live Brew tidak ditemukan di server. Pastikan QR aktif atau koneksi internet stabil.';
      });
    }
  }

  void _applyResolution(BrandedSeatResolution res) {
    _resolution = res;
    if (res.activeBrewSession != null) {
      _snapshot = res.activeBrewSession;
      _localCheers = res.activeBrewSession!.cheersCount;
      _timerEngine.applyAuthoritativeSnapshot(
        res.activeBrewSession!,
        forceReset: true,
      );
    }
  }

  Future<void> _calibrateNtp(LiveBrewV2ApiService api) async {
    if (_isTestEnv) return;
    for (var i = 0; i < 3; i++) {
      final t1 = DateTime.now().millisecondsSinceEpoch;
      final pong = await api.pingNtp(t1);
      if (pong != null) {
        _timerEngine.recordNtpPong(
          clientSendMs: pong['client_send_ms'] ?? t1,
          serverRecvMs: pong['server_recv_ms'] ?? t1,
          serverSendMs: pong['server_send_ms'] ?? t1,
        );
      }
    }
  }

  Future<void> _connectViewerWs(LiveBrewV2ApiService api) async {
    if (_isTestEnv) return;
    await _closeSocket();
    final targetKey = widget.target.streamTargetKey;
    if (targetKey.isEmpty) return;

    try {
      final (wsBase, _) = await api.resolveWsBaseAndToken();
      final uri = Uri.parse('$wsBase/api/v1/livebrew/v2/stream/$targetKey/ws');
      _ws = WebSocketChannel.connect(uri);
      if (mounted) setState(() => _wsConnected = true);

      _wsSub = _ws!.stream.listen(
        _handleWsMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
      );

      _ws!.sink.add(
        jsonEncode({
          'cmd': 'NTP_PING',
          'client_send_ms': DateTime.now().millisecondsSinceEpoch,
        }),
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _handleWsMessage(dynamic raw) {
    if (!mounted) return;
    try {
      final ev = jsonDecode(raw.toString()) as Map<String, dynamic>;
      final type = ev['event']?.toString();
      if (type == 'ntp_pong') {
        _timerEngine.recordNtpPong(
          clientSendMs: ((ev['client_send_ms'] as num?) ?? 0).toInt(),
          serverRecvMs: ((ev['server_recv_ms'] as num?) ?? 0).toInt(),
          serverSendMs: ((ev['server_send_ms'] as num?) ?? 0).toInt(),
        );
        setState(() {});
      } else if (type == 'mirror_snapshot') {
        final snap = LiveSessionMirrorSnapshot.fromJson(ev);
        if (_timerEngine.applyAuthoritativeSnapshot(snap)) {
          setState(() {
            _snapshot = snap;
            _localCheers = snap.cheersCount;
          });
        }
      } else if (type == 'cheer_burst') {
        final total = ((ev['total_cheers'] as num?) ?? _localCheers).toInt();
        setState(() => _localCheers = total);
      } else if (type == 'pos_order_updated') {
        setState(() {
          _resolution = BrandedSeatResolution(
            resolutionKind: 'POS_ORDER_QUEUED',
            branding: _resolution?.branding,
            seat: _resolution?.seat,
            posOrderProgress: PosOrderProgressModel(
              posOrderId: ev['pos_order_id']?.toString(),
              posOrderNumber: (ev['pos_order_number'] ?? '').toString(),
              posOrderStatus: (ev['pos_order_status'] ?? 'QUEUED').toString(),
              queuePositionAhead:
                  ((ev['queue_position_ahead'] as num?) ?? 0).toInt(),
              itemsSummary:
                  (ev['items_summary'] ?? 'Specialty Coffee').toString(),
              customerName: (ev['customer_name'] ?? 'Pelanggan').toString(),
            ),
            activeBrewSession: _snapshot,
            serverEpochMs: DateTime.now().millisecondsSinceEpoch,
          );
        });
      }
    } catch (_) {}
  }

  void _scheduleReconnect() {
    if (!mounted || _isTestEnv) return;
    setState(() => _wsConnected = false);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      _connectViewerWs(ref.read(liveBrewV2ApiProvider));
    });
  }

  Future<void> _closeSocket() async {
    await _wsSub?.cancel();
    _wsSub = null;
    await _ws?.sink.close();
    _ws = null;
  }

  Future<void> _sendCheer() async {
    if (_sendingCheer) return;
    setState(() => _sendingCheer = true);
    try {
      final api = ref.read(liveBrewV2ApiProvider);
      final targetKey =
          _snapshot?.shareCode ?? widget.target.streamTargetKey;
      final total = await api.sendCheer(targetKey, 'clap');
      if (mounted) {
        setState(() {
          _localCheers = total > 0 ? total : _localCheers + 1;
          _sendingCheer = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _sendingCheer = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branding = _resolution?.branding;
    final seat = _resolution?.seat;
    final posOrder = _resolution?.posOrderProgress;
    final accentColor = branding?.accentColor ?? const Color(0xFFD4A373);

    if (_loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: accentColor),
              const SizedBox(height: 14),
              const Text(
                'Menghubungkan ke Studio Barista & Kalibrasi NTP...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF9F5EE),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1714),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4A373).withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFFD4A373),
                  size: 38,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF9F5EE),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A373),
                        foregroundColor: const Color(0xFF12100E),
                      ),
                      onPressed: _resolveAndConnect,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text(
                        'Coba Hubungkan Ulang',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (widget.onClose != null)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF9F5EE),
                          side: const BorderSide(color: Color(0xFFD4A373)),
                        ),
                        onPressed: widget.onClose,
                        child: const Text('Ganti Kode / Meja'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: accentColor,
      backgroundColor: const Color(0xFF1C1714),
      onRefresh: _resolveAndConnect,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // 1. Connection & Cafe Branding Header
          _buildBrandingHeader(branding, seat, accentColor),
          const SizedBox(height: 12),

          // 2. POS Order Progress Stepper (jika terhubung ke POS Bisnis)
          if (posOrder != null || _snapshot?.posOrderNumber != null) ...[
            _buildPosProgressCard(posOrder, _snapshot, branding, accentColor),
            const SizedBox(height: 12),
          ],

          // 3. Real-Time Brew State (Idle vs Active 1:1 Mirror)
          if (_snapshot == null)
            _buildBrandedIdleWaitingCard(branding, seat, accentColor)
          else ...[
            // 1:1 NTP Circular Timer Card
            MirroredCircularTimerCard(
              snapshot: _snapshot!,
              timerEngine: _timerEngine,
              accentColor: accentColor,
              clockOffsetMs: _timerEngine.clockOffsetMs,
            ),
            const SizedBox(height: 12),

            // Live Recipe Preview (terlihat sejak brewer baru memilih resep!)
            _buildLiveRecipeCard(_snapshot!, accentColor),
            const SizedBox(height: 12),

            // Live Bean Passport Preview (terlihat saat brewer memilih biji)
            if (branding?.showLiveBeanDetails != false) ...[
              _buildLiveBeanCard(_snapshot!, accentColor),
              const SizedBox(height: 12),
            ],

            // Interactive Cheer Bar
            _buildCheerBar(_snapshot!, accentColor),
            const SizedBox(height: 12),

            // Digital Cup Passport saat SERVING_READY_PASSPORT
            if (_snapshot!.phase == LiveBrewMirrorPhase.servingReadyPassport)
              _buildDigitalCupPassportCard(_snapshot!, accentColor),
          ],
        ],
      ),
    );
  }

  Widget _buildBrandingHeader(
    BusinessBrandingModel? branding,
    CafeSeatModel? seat,
    Color accentColor,
  ) {
    final cafeName = branding?.cafeDisplayName ??
        (_snapshot != null
            ? 'Studio Seduh ${_snapshot!.brewerDisplayName}'
            : 'Coffee Labs Live Brewing');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                ),
                child: Icon(
                  Icons.local_cafe_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF9F5EE),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      seat != null
                          ? '${seat.seatLabel} • ${seat.zoneArea}'
                          : 'Kode Live: ${_snapshot?.shareCode ?? widget.target.streamTargetKey}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _wsConnected
                      ? const Color(0xFF16A34A).withValues(alpha: 0.18)
                      : const Color(0xFFD97706).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _wsConnected
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFF59E0B),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _wsConnected
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _wsConnected ? 'LIVE' : 'SYNC',
                      style: const TextStyle(
                        color: Color(0xFFF9F5EE),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (branding != null && branding.welcomeMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              branding.welcomeMessage,
              style: const TextStyle(
                color: Color(0xFFCBBFB2),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          if (branding?.wifiSsid != null &&
              branding!.wifiSsid!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                final pass = branding.wifiPassword ?? '';
                if (pass.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: pass));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Password Wi-Fi "${branding.wifiSsid}" disalin!',
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF12100E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_rounded, color: accentColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Wi-Fi: ${branding.wifiSsid}${(branding.wifiPassword ?? '').isNotEmpty ? ' • Sandi: ${branding.wifiPassword}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFF9F5EE),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.doc_on_clipboard,
                      color: accentColor,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (widget.onClose != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: widget.onClose,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 15),
                label: const Text(
                  'Pindai QR Lain',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPosProgressCard(
    PosOrderProgressModel? posOrder,
    LiveSessionMirrorSnapshot? snap,
    BusinessBrandingModel? branding,
    Color accentColor,
  ) {
    final orderNo = posOrder?.posOrderNumber ?? snap?.posOrderNumber ?? '';
    final customer = posOrder?.customerName ?? snap?.customerName ?? 'Pelanggan';
    final status = (posOrder?.posOrderStatus ?? snap?.posOrderStatus ?? 'QUEUED')
        .toUpperCase();
    final stepIdx = _posStepIndex(status, snap?.phase);
    const labels = ['Masuk POS', 'Pilih Resep', 'Diseduh', 'Disajikan'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pesanan POS $orderNo • $customer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF9F5EE),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (branding?.showPosQueuePosition != false &&
                  posOrder != null &&
                  posOrder.queuePositionAhead > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Antrean #${posOrder.queuePositionAhead}',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          if (posOrder != null && posOrder.itemsSummary.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              posOrder.itemsSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFCBBFB2),
                fontSize: 11.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: List.generate(labels.length, (i) {
              final active = i <= stepIdx;
              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (i > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: active
                                  ? accentColor
                                  : Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active
                                ? accentColor
                                : const Color(0xFF12100E),
                            border: Border.all(
                              color: active
                                  ? accentColor
                                  : Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(
                            active ? Icons.check_rounded : Icons.circle,
                            size: active ? 13 : 6,
                            color: active
                                ? const Color(0xFF12100E)
                                : Colors.white38,
                          ),
                        ),
                        if (i < labels.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: i < stepIdx
                                  ? accentColor
                                  : Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active
                            ? const Color(0xFFF9F5EE)
                            : const Color(0xFF9C8F82),
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  int _posStepIndex(String posStatus, LiveBrewMirrorPhase? phase) {
    if (phase == LiveBrewMirrorPhase.servingReadyPassport ||
        posStatus == 'SERVED' ||
        posStatus == 'READY') {
      return 3;
    }
    if (phase == LiveBrewMirrorPhase.brewingActive ||
        phase == LiveBrewMirrorPhase.brewingPaused ||
        posStatus == 'BREWING') {
      return 2;
    }
    if (phase == LiveBrewMirrorPhase.brewerSelectingRecipe ||
        phase == LiveBrewMirrorPhase.brewerSelectingBean ||
        phase == LiveBrewMirrorPhase.preBrewCalibrated) {
      return 1;
    }
    return 0;
  }

  Widget _buildBrandedIdleWaitingCard(
    BusinessBrandingModel? branding,
    CafeSeatModel? seat,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.32)),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.15),
              border: Border.all(color: accentColor.withValues(alpha: 0.5)),
            ),
            child: Icon(
              Icons.coffee_maker_rounded,
              color: accentColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            seat != null
                ? '${seat.seatLabel} Terhubung Live'
                : 'Menunggu Barista Memulai Seduhan',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFF9F5EE),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Halaman ini tersinkronisasi otomatis secara real-time. Begitu barista mulai memilih resep, menimbang biji kopi, dan menyalakan timer seduh, seluruh proses langsung tampil 1:1 di layar Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFCBBFB2),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveRecipeCard(
    LiveSessionMirrorSnapshot snap,
    Color accentColor,
  ) {
    final hasRecipe = (snap.selectedRecipeTitle ?? '').isNotEmpty;
    final steps = snap.recipeSteps;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, color: accentColor, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Resep & Tahapan Seduh Barista',
                  style: TextStyle(
                    color: Color(0xFFF9F5EE),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (snap.selectedMethodName != null &&
                  snap.selectedMethodName!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    snap.selectedMethodName!,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (!hasRecipe)
            const Text(
              'Barista sedang meninjau metode dan memilih resep yang paling cocok...',
              style: TextStyle(color: Color(0xFFCBBFB2), fontSize: 12),
            )
          else ...[
            Text(
              snap.selectedRecipeTitle!,
              style: const TextStyle(
                color: Color(0xFFF9F5EE),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _specChip('Dosis ${snap.targetDoseG.toStringAsFixed(0)}g', accentColor),
                _specChip('Air ${snap.targetWaterMl.toStringAsFixed(0)}ml', accentColor),
                _specChip('Suhu ${snap.currentTempC.toStringAsFixed(0)}°C', accentColor),
                _specChip(
                  'Target ${NtpSyncedTimerEngine.formatMmSs(snap.targetDurationSeconds * 1000)}',
                  accentColor,
                ),
              ],
            ),
            if (steps.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final st = entry.value;
                final isActive = idx == snap.currentStepIndex &&
                    snap.phase == LiveBrewMirrorPhase.brewingActive;
                final isDone = idx < snap.currentStepIndex ||
                    snap.phase == LiveBrewMirrorPhase.servingReadyPassport;
                final title = (st['title'] ?? st['name'] ?? 'Tahap ${idx + 1}')
                    .toString();
                final dur = ((st['durationSeconds'] ?? st['duration'] ?? 30) as num)
                    .toInt();
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? accentColor.withValues(alpha: 0.16)
                        : const Color(0xFF12100E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? accentColor
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDone
                            ? Icons.check_circle_rounded
                            : (isActive
                                ? Icons.play_circle_filled_rounded
                                : Icons.radio_button_unchecked_rounded),
                        size: 16,
                        color: isDone
                            ? const Color(0xFF22C55E)
                            : (isActive ? accentColor : Colors.white38),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFFF9F5EE)
                                : const Color(0xFFCBBFB2),
                            fontSize: 12,
                            fontWeight:
                                isActive ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${dur}d',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildLiveBeanCard(
    LiveSessionMirrorSnapshot snap,
    Color accentColor,
  ) {
    final bean = snap.beanSnapshot;
    final beanName = (bean['name'] ?? bean['bean_name'] ?? '').toString();
    final roastery = (bean['roastery'] ?? bean['roaster'] ?? '').toString();
    final origin = (bean['origin'] ?? '').toString();
    final process = (bean['process'] ?? '').toString();
    final roastLevel = (bean['roast_level'] ?? bean['roastLevel'] ?? '').toString();
    final notesRaw = bean['tasting_notes'] ?? bean['notes'];
    final notes = notesRaw is List
        ? notesRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : (notesRaw?.toString().isNotEmpty == true
            ? notesRaw.toString().split(',').map((e) => e.trim()).toList()
            : <String>[]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grain_rounded, color: accentColor, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Profil Biji Kopi (Live Bean Passport)',
                  style: TextStyle(
                    color: Color(0xFFF9F5EE),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (beanName.isEmpty)
            const Text(
              'Menunggu barista memilih biji kopi untuk cangkir Anda...',
              style: TextStyle(color: Color(0xFFCBBFB2), fontSize: 12),
            )
          else ...[
            Text(
              beanName,
              style: const TextStyle(
                color: Color(0xFFF9F5EE),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (roastery.isNotEmpty || origin.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                [roastery, origin].where((e) => e.isNotEmpty).join(' • '),
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (process.isNotEmpty || roastLevel.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (process.isNotEmpty) _specChip('Proses: $process', accentColor),
                  if (roastLevel.isNotEmpty) _specChip('Sangrai: $roastLevel', accentColor),
                ],
              ),
            ],
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: notes
                    .take(6)
                    .map(
                      (n) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          n,
                          style: const TextStyle(
                            color: Color(0xFFF9F5EE),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCheerBar(LiveSessionMirrorSnapshot snap, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barista: ${snap.brewerDisplayName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF9F5EE),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${snap.activeViewersCount} penonton • $_localCheers apresiasi',
                  style: const TextStyle(
                    color: Color(0xFFCBBFB2),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: const Color(0xFF12100E),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _sendingCheer ? null : _sendCheer,
            icon: const Icon(Icons.favorite_rounded, size: 15),
            label: const Text(
              'Semangat!',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalCupPassportCard(
    LiveSessionMirrorSnapshot snap,
    Color accentColor,
  ) {
    final finalTime = NtpSyncedTimerEngine.formatMmSs(snap.timerAccumulatedMs);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1F2B1D),
            const Color(0xFF1C1714),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_rounded, color: Color(0xFF22C55E), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Digital Cup Passport — Kopi Siap Dinikmati!',
                  style: TextStyle(
                    color: Color(0xFFF9F5EE),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Seduhan selesai dalam $finalTime dengan berat akhir ${snap.currentWeightG.toStringAsFixed(1)} g oleh ${snap.brewerDisplayName}.',
            style: const TextStyle(
              color: Color(0xFFCBBFB2),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: const Color(0xFF0A140B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                final summary =
                    'Coffee Labs Cup Passport\nResep: ${snap.selectedRecipeTitle ?? 'Specialty Brew'} (${snap.selectedMethodName ?? 'Manual Brew'})\nWaktu: $finalTime | Berat Akhir: ${snap.currentWeightG.toStringAsFixed(1)}g\nBarista: ${snap.brewerDisplayName}';
                Clipboard.setData(ClipboardData(text: summary));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Resep & Digital Cup Passport berhasil disalin ke catatan Anda!',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bookmark_added_rounded, size: 17),
              label: const Text(
                'Simpan Resep & Cup Passport Ini',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _specChip(String label, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF12100E),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFF9F5EE),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
