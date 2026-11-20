import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/qris_billing_api_service.dart';
import '../../domain/qris_billing_models.dart';

/// Panel Khusus Pemilik / Superadmin Coffee Labs:
/// 1. Aktivasi Android Livin' Merchant Notification Bridge (`id.bmri.livinmerchant`)
/// 2. Verifikasi & Uji EMVCo Dynamic QRIS + CRC-16 (`Coffeelabs`)
/// 3. Pantau Mutasi Livin' Merchant Masuk & 1-Tap Approve Invoice `MANUAL_REVIEW`
class MerchantQrisBridgeAdminScreen extends ConsumerStatefulWidget {
  const MerchantQrisBridgeAdminScreen({super.key});

  @override
  ConsumerState<MerchantQrisBridgeAdminScreen> createState() =>
      _MerchantQrisBridgeAdminScreenState();
}

class _MerchantQrisBridgeAdminScreenState
    extends ConsumerState<MerchantQrisBridgeAdminScreen> {
  final TextEditingController _secretCtrl = TextEditingController();
  final TextEditingController _apiUrlCtrl =
      TextEditingController(text: 'https://coffe-labs-backend.onrender.com');
  final TextEditingController _testAmountCtrl =
      TextEditingController(text: '49317');

  MerchantBridgeStatusModel _nativeStatus = const MerchantBridgeStatusModel();
  AdminBridgeInfoModel? _serverInfo;
  List<DynamicQrisInvoiceModel> _pendingInvoices = const [];
  List<UnmatchedMutationModel> _mutations = const [];
  String? _testQrisPayload;
  bool _bridgeEnabled = false;
  bool _loading = true;
  bool _savingBridge = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadAll);
  }

  @override
  void dispose() {
    _secretCtrl.dispose();
    _apiUrlCtrl.dispose();
    _testAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final api = ref.read(qrisBillingApiProvider);
    final native = await QrisBridgePlatformChannel.getStatus();
    AdminBridgeInfoModel? info;
    List<DynamicQrisInvoiceModel> pending = const [];
    List<UnmatchedMutationModel> muts = const [];
    try {
      info = await api.fetchAdminBridgeInfo();
      pending = await api.fetchPendingInvoices();
      muts = await api.fetchRecentMutations();
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _nativeStatus = native;
      _bridgeEnabled = native.enabled;
      _apiUrlCtrl.text = native.apiBaseUrl;
      _serverInfo = info;
      if (_secretCtrl.text.isEmpty && info != null) {
        _secretCtrl.text = info.bridgeHmacSecret;
      }
      _pendingInvoices = pending;
      _mutations = muts;
      _loading = false;
    });
  }

  Future<void> _saveNativeBridge() async {
    setState(() => _savingBridge = true);
    final ok = await QrisBridgePlatformChannel.configure(
      enabled: _bridgeEnabled,
      bridgeSecret: _secretCtrl.text.trim(),
      apiBaseUrl: _apiUrlCtrl.text.trim(),
    );
    await _loadAll();
    if (!mounted) return;
    setState(() => _savingBridge = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Konfigurasi Livin\' Merchant Bridge tersimpan di perangkat ini!'
              : 'Mode Bridge Native hanya tersedia pada perangkat Android.',
        ),
      ),
    );
  }

  Future<void> _runTestQris() async {
    final amt = int.tryParse(_testAmountCtrl.text.trim()) ?? 49317;
    try {
      final res =
          await ref.read(qrisBillingApiProvider).adminTestDynamicQris(amt);
      if (!mounted) return;
      setState(() {
        _testQrisPayload = res['dynamic_qris_payload']?.toString();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal uji QRIS: $e')));
    }
  }

  Future<void> _approveInvoice(DynamicQrisInvoiceModel inv) async {
    try {
      await ref
          .read(qrisBillingApiProvider)
          .adminApproveInvoice(inv.invoiceId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF166534),
          content: Text(
            'Invoice ${inv.invoiceNumber} disetujui! Akun user langsung aktif (${inv.targetTier.toUpperCase()}).',
          ),
        ),
      );
      await _loadAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF991B1B),
          content: Text('Gagal menyetujui invoice: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12100E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12100E),
        foregroundColor: const Color(0xFFF9F5EE),
        iconTheme: const IconThemeData(color: Color(0xFFF9F5EE)),
        title: const Text(
          'Merchant QRIS Bridge & Rekonsiliasi',
          style: TextStyle(
            color: Color(0xFFF9F5EE),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD4A373)),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4A373)),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              children: [
                // 1. Verified Master QRIS Status
                _card(
                  title: 'Status Master QRIS Statis (Livin\' Merchant)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_serverInfo?.merchantName ?? 'Coffeelabs'} • ${_serverInfo?.merchantCity ?? 'Bandung (Kab)'}',
                        style: const TextStyle(
                          color: Color(0xFFF9F5EE),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Acquirer: ${_serverInfo?.acquirerCode ?? '93600008'} (Bank Mandiri) • NMID: ${_serverInfo?.nmid ?? 'ID1023277752888'}',
                        style: const TextStyle(
                          color: Color(0xFFCBBFB2),
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _pill(
                            _serverInfo?.staticQrisCrcValid == true
                                ? 'CRC-16 VALID'
                                : 'PERIKSA MASTER QRIS',
                            _serverInfo?.staticQrisCrcValid == true
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFF59E0B),
                          ),
                          _pill(
                            _serverInfo?.imapWatcherConfigured == true
                                ? 'Layer 2 IMAP 24/7 AKTIF'
                                : 'Layer 2 IMAP Standby',
                            const Color(0xFFD4A373),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Android Livin' Merchant Notification Bridge Setup
                _card(
                  title: 'Channel A: Android Livin\' Merchant Bridge',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _nativeStatus.hasNotificationAccess
                                  ? 'Izin Akses Notifikasi: AKTIF'
                                  : 'Izin Akses Notifikasi: BELUM DIBERIKAN',
                              style: TextStyle(
                                color: _nativeStatus.hasNotificationAccess
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFF59E0B),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await QrisBridgePlatformChannel
                                  .openNotificationAccessSettings();
                            },
                            child: const Text(
                              'Buka Izin OS',
                              style: TextStyle(
                                color: Color(0xFFD4A373),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: const Color(0xFFD4A373),
                        title: const Text(
                          'Aktifkan Listener id.bmri.livinmerchant',
                          style: TextStyle(
                            color: Color(0xFFF9F5EE),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: const Text(
                          'Aktifkan HANYA di HP merchant yang terpasang Livin\' Merchant.',
                          style: TextStyle(
                            color: Color(0xFF9C8F82),
                            fontSize: 11,
                          ),
                        ),
                        value: _bridgeEnabled,
                        onChanged: (v) => setState(() => _bridgeEnabled = v),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _secretCtrl,
                        style: const TextStyle(
                          color: Color(0xFFF9F5EE),
                          fontSize: 12,
                        ),
                        decoration: _inputDeco('HMAC-SHA256 Bridge Secret'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _apiUrlCtrl,
                        style: const TextStyle(
                          color: Color(0xFFF9F5EE),
                          fontSize: 12,
                        ),
                        decoration: _inputDeco('Backend Server URL'),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A373),
                            foregroundColor: const Color(0xFF12100E),
                          ),
                          onPressed: _savingBridge ? null : _saveNativeBridge,
                          icon: const Icon(Icons.save_rounded, size: 17),
                          label: const Text(
                            'Simpan Konfigurasi Bridge HP Ini',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Uji Generasi EMVCo Dynamic QRIS
                _card(
                  title: 'Uji Generator EMVCo QRIS Dinamis & CRC-16',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _testAmountCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Color(0xFFF9F5EE),
                                fontSize: 13,
                              ),
                              decoration: _inputDeco('Nominal Uji (IDR)'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4A373),
                              foregroundColor: const Color(0xFF12100E),
                            ),
                            onPressed: _runTestQris,
                            child: const Text(
                              'Generate',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      if (_testQrisPayload != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: QrImageView(
                            data: _testQrisPayload!,
                            size: 165,
                            errorCorrectionLevel: QrErrorCorrectLevel.M,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Pending / Manual Review Invoices (1-Tap Approve)
                _card(
                  title: 'Invoice Menunggu / Manual Review (${_pendingInvoices.length})',
                  child: _pendingInvoices.isEmpty
                      ? const Text(
                          'Tidak ada invoice tertunda saat ini.',
                          style: TextStyle(
                            color: Color(0xFF9C8F82),
                            fontSize: 12,
                          ),
                        )
                      : Column(
                          children: _pendingInvoices.map((inv) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF12100E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${inv.invoiceNumber} • ${inv.formattedTotal}',
                                          style: const TextStyle(
                                            color: Color(0xFFF9F5EE),
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${inv.planCode} • Status: ${inv.status}',
                                          style: const TextStyle(
                                            color: Color(0xFFCBBFB2),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF22C55E),
                                      foregroundColor: const Color(0xFF0A140B),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () => _approveInvoice(inv),
                                    child: const Text(
                                      'Approve',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 12),

                // 5. Recent Livin' Merchant Mutations Ledger
                _card(
                  title: 'Buku Besar Mutasi Masuk (${_mutations.length})',
                  child: _mutations.isEmpty
                      ? const Text(
                          'Belum ada mutasi Livin\' Merchant yang tercatat.',
                          style: TextStyle(
                            color: Color(0xFF9C8F82),
                            fontSize: 12,
                          ),
                        )
                      : Column(
                          children: _mutations.take(15).map((m) {
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                CupertinoIcons.money_dollar_circle_fill,
                                color: m.reconciliationStatus == 'MATCHED_AUTO'
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFD4A373),
                              ),
                              title: Text(
                                '${formatRupiahIdr(m.amountIdr)} • ${m.reconciliationStatus}',
                                style: const TextStyle(
                                  color: Color(0xFFF9F5EE),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                '${m.sourceChannel} — ${m.rawNotificationText}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF9C8F82),
                                  fontSize: 11,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1714),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4A373).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD4A373),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF9C8F82), fontSize: 11.5),
      filled: true,
      fillColor: const Color(0xFF12100E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(
          color: const Color(0xFFD4A373).withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFD4A373)),
      ),
    );
  }
}
