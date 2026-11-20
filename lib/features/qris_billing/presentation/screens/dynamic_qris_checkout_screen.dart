import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/qris_billing_models.dart';
import '../controllers/qris_checkout_controller.dart';
import '../services/qris_image_saver_service.dart';
import 'subscription_activated_success_screen.dart';

class DynamicQrisCheckoutScreen extends ConsumerStatefulWidget {
  final DynamicQrisInvoiceModel initialInvoice;

  const DynamicQrisCheckoutScreen({
    super.key,
    required this.initialInvoice,
  });

  @override
  ConsumerState<DynamicQrisCheckoutScreen> createState() =>
      _DynamicQrisCheckoutScreenState();
}

class _DynamicQrisCheckoutScreenState
    extends ConsumerState<DynamicQrisCheckoutScreen>
    with WidgetsBindingObserver {
  final GlobalKey _qrisCardKey = GlobalKey();
  late final ValueNotifier<int> _remainingSecNotifier;
  Timer? _countdownTimer;
  bool _savingGallery = false;
  bool _sharingImage = false;
  bool _navigatedSuccess = false;

  bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final diff =
        widget.initialInvoice.expiresAt.difference(DateTime.now()).inSeconds;
    _remainingSecNotifier = ValueNotifier<int>(diff.clamp(0, 3600));

    Future.microtask(() {
      final ctrl = ref.read(qrisCheckoutProvider.notifier);
      final current = ref.read(qrisCheckoutProvider).activeInvoice;
      if (current == null || current.invoiceId != widget.initialInvoice.invoiceId) {
        ctrl.attachExistingInvoice(widget.initialInvoice);
      }
    });

    if (!_isTestEnv) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final next = widget.initialInvoice.expiresAt
            .difference(DateTime.now())
            .inSeconds
            .clamp(0, 3600);
        if (_remainingSecNotifier.value != next) {
          _remainingSecNotifier.value = next;
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(qrisCheckoutProvider.notifier).checkInvoiceStatusNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _remainingSecNotifier.dispose();
    super.dispose();
  }

  String _formatCountdown(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _saveQrisCardToDevice(DynamicQrisInvoiceModel invoice) async {
    if (_savingGallery) return;
    setState(() => _savingGallery = true);
    try {
      final bytes =
          await QrisImageSaverService.captureRepaintBoundaryPng(_qrisCardKey);
      final res = await QrisImageSaverService.saveQrisImage(
        pngBytes: bytes,
        baseFileName: 'QRIS_${invoice.merchantName}_${invoice.totalPayableIdr}',
        merchantName: invoice.merchantName,
        formattedAmount: invoice.formattedTotal,
      );
      if (!mounted) return;
      if (res.success) HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          backgroundColor:
              res.success ? const Color(0xFF166534) : const Color(0xFF991B1B),
          content: Text(res.displayMessage),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF991B1B),
          content: Text('Gagal menyimpan gambar QRIS: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingGallery = false);
    }
  }

  Future<void> _shareQrisCard(DynamicQrisInvoiceModel invoice) async {
    if (_sharingImage) return;
    setState(() => _sharingImage = true);
    try {
      final bytes =
          await QrisImageSaverService.captureRepaintBoundaryPng(_qrisCardKey);
      await QrisImageSaverService.shareQrisImage(
        pngBytes: bytes,
        baseFileName: 'QRIS_${invoice.merchantName}_${invoice.totalPayableIdr}',
        shareText:
            'Pembayaran QRIS ${invoice.merchantName} — ${invoice.isBusiness ? 'Coffee Labs Business' : 'Coffee Labs Pro'} sebesar ${invoice.formattedTotal} (${invoice.invoiceNumber}).',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF991B1B),
          content: Text('Gagal membagikan gambar QRIS: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _sharingImage = false);
    }
  }

  Future<void> _openInstantVerificationSheet(
    DynamicQrisInvoiceModel invoice,
  ) async {
    // Cek dulu apakah pembayaran sudah terdeteksi otomatis di server
    final detected =
        await ref.read(qrisCheckoutProvider.notifier).checkInvoiceStatusNow();
    if (detected || !mounted) return;

    final rrnCtrl = TextEditingController();
    Uint8List? pickedBytes;
    String? pickedName;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1714),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isVerifying =
                ref.watch(qrisCheckoutProvider).isVerifyingPayment;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                MediaQuery.of(ctx).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF22C55E),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Verifikasi Pembayaran ${invoice.formattedTotal}',
                          style: const TextStyle(
                            color: Color(0xFFF9F5EE),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sudah membayar QRIS ${invoice.merchantName} sebesar ${invoice.formattedTotal}? Masukkan Nomor RRN struk (opsional) atau lampirkan bukti bayar untuk langsung mengaktifkan ${invoice.isBusiness ? 'Coffee Labs Business' : 'Coffee Labs Pro'}.',
                    style: const TextStyle(
                      color: Color(0xFFCBBFB2),
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rrnCtrl,
                    style: const TextStyle(
                      color: Color(0xFFF9F5EE),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nomor RRN / Referensi QRIS (Opsional)',
                      hintText: 'Contoh: 379122962',
                      labelStyle: const TextStyle(
                        color: Color(0xFFD4A373),
                        fontSize: 11.5,
                      ),
                      hintStyle: const TextStyle(
                        color: Color(0xFF78716C),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF12100E),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: BorderSide(
                          color: const Color(0xFFD4A373).withValues(alpha: 0.35),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11),
                        borderSide: const BorderSide(color: Color(0xFFD4A373)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD4A373),
                            side: BorderSide(
                              color: const Color(0xFFD4A373)
                                  .withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          onPressed: isVerifying
                              ? null
                              : () async {
                                  final picker = ImagePicker();
                                  final file = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 85,
                                    maxWidth: 1600,
                                  );
                                  if (file == null) return;
                                  final b = await file.readAsBytes();
                                  setModalState(() {
                                    pickedBytes = b;
                                    pickedName = file.name;
                                  });
                                },
                          icon: Icon(
                            pickedBytes != null
                                ? Icons.check_circle_rounded
                                : Icons.receipt_long_rounded,
                            size: 16,
                            color: pickedBytes != null
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFD4A373),
                          ),
                          label: Text(
                            pickedName != null
                                ? 'Struk Terlampir ($pickedName)'
                                : 'Lampirkan Struk (Opsional)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: const Color(0xFF052E16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isVerifying
                          ? null
                          : () async {
                              final ok = await ref
                                  .read(qrisCheckoutProvider.notifier)
                                  .verifyAndActivatePayment(
                                    rrnOrReference: rrnCtrl.text.trim(),
                                    imageBytes: pickedBytes,
                                    filename: pickedName,
                                  );
                              if (ctx.mounted) {
                                Navigator.of(ctx).pop();
                              }
                              if (!ok && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF991B1B),
                                    content: Text(
                                      ref
                                              .read(qrisCheckoutProvider)
                                              .errorMessage ??
                                          'Gagal memverifikasi pembayaran.',
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: isVerifying
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF052E16),
                              ),
                            )
                          : const Icon(Icons.bolt_rounded, size: 18),
                      label: Text(
                        isVerifying
                            ? 'Memverifikasi Pembayaran...'
                            : 'Konfirmasi & Aktifkan Lisensi Sekarang',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<QrisCheckoutState>(qrisCheckoutProvider, (prev, next) {
      if (!_navigatedSuccess && next.confirmedTier != null) {
        _navigatedSuccess = true;
        final inv = next.activeInvoice ?? widget.initialInvoice;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SubscriptionActivatedSuccessScreen(
              newTier: next.confirmedTier!,
              invoiceNumber: inv.invoiceNumber,
              amountPaidLabel: inv.formattedTotal,
              expiresAt: next.confirmedExpiresAt,
              isLifetime: inv.isLifetime,
            ),
          ),
        );
      }
    });

    final state = ref.watch(qrisCheckoutProvider);
    final invoice = state.activeInvoice ?? widget.initialInvoice;

    return Scaffold(
      backgroundColor: const Color(0xFF12100E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12100E),
        foregroundColor: const Color(0xFFF9F5EE),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 46,
        iconTheme: const IconThemeData(color: Color(0xFFF9F5EE)),
        title: const Text(
          'Pembayaran QRIS',
          style: TextStyle(
            color: Color(0xFFF9F5EE),
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: _remainingSecNotifier,
                builder: (_, sec, _) {
                  final urgent = sec < 180;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: urgent
                          ? const Color(0xFFDC2626).withValues(alpha: 0.22)
                          : const Color(0xFFD4A373).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: urgent
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFD4A373),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.timer,
                          size: 12,
                          color: urgent
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFD4A373),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatCountdown(sec),
                          style: const TextStyle(
                            color: Color(0xFFF9F5EE),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
        children: [
          // Compact Selected Plan Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1714),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4A373).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  invoice.isBusiness
                      ? Icons.storefront_rounded
                      : CupertinoIcons.sparkles,
                  color: const Color(0xFFD4A373),
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    invoice.isBusiness
                        ? 'Coffee Labs Business • Sekali Bayar'
                        : 'Coffee Labs Pro • Sekali Bayar',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF9F5EE),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(
                    color: Color(0xFFD4A373),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // COMPACT BRANDED QRIS CARD (RepaintBoundary 3x DPI — 100% Scannable)
          RepaintBoundary(
            key: _qrisCardKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFD4A373),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header QRIS & GPN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12100E),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'QRIS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          invoice.merchantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF12100E),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'GPN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'NMID: ${invoice.nmid} • Acquirer ${invoice.acquirerCode}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Crisp Compact EMVCo QR Code
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: QrImageView(
                      data: invoice.dynamicQrisPayload,
                      version: QrVersions.auto,
                      size: 164,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Nominal + Copy Button
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        invoice.formattedTotal,
                        style: const TextStyle(
                          color: Color(0xFF12100E),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: invoice.totalPayableIdr.toString(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Nominal ${invoice.formattedTotal} disalin!',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3EFEA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFD4A373)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.doc_on_clipboard,
                                size: 12,
                                color: Color(0xFF5D3A1A),
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Salin Nominal',
                                style: TextStyle(
                                  color: Color(0xFF5D3A1A),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Harga Paket ${invoice.formattedBase} + Kode Unik Rp ${invoice.uniqueCodeIdr}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (invoice.appliedReferralCode != null &&
                      invoice.buyerDiscountIdr > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        'Referral ${invoice.appliedReferralCode} • Diskon ${formatRupiahIdr(invoice.buyerDiscountIdr)}',
                        style: const TextStyle(
                          color: Color(0xFF166534),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  const Text(
                    'Nominal otomatis sesuai saat QRIS dipindai',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF15803D),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Row 1: Save QRIS Image + Share
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A373),
                      foregroundColor: const Color(0xFF12100E),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _savingGallery
                        ? null
                        : () => _saveQrisCardToDevice(invoice),
                    icon: _savingGallery
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF12100E),
                            ),
                          )
                        : const Icon(Icons.download_rounded, size: 17),
                    label: const Text(
                      'Simpan Gambar QRIS ke Galeri',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 42,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD4A373),
                    side: const BorderSide(color: Color(0xFFD4A373)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      _sharingImage ? null : () => _shareQrisCard(invoice),
                  child: _sharingImage
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFD4A373),
                          ),
                        )
                      : const Icon(CupertinoIcons.share, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Instant Verification & Activation CTA (100% visible above the fold)
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: const Color(0xFF052E16),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: state.isVerifyingPayment
                  ? null
                  : () => _openInstantVerificationSheet(invoice),
              icon: state.isVerifyingPayment
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF052E16),
                      ),
                    )
                  : const Icon(Icons.verified_rounded, size: 17),
              label: Text(
                state.isVerifyingPayment
                    ? 'Memverifikasi Pembayaran...'
                    : 'Sudah Bayar? Verifikasi & Aktifkan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Row 3: Compact Auto-Detection Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1714),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF22C55E).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: invoice.isExpired
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    invoice.isExpired
                        ? 'QRIS kedaluwarsa. Silakan buat kode QRIS baru.'
                        : 'Deteksi pembayaran otomatis aktif • Scan via BCA, Livin\', GoPay, OVO, DANA',
                    style: const TextStyle(
                      color: Color(0xFFCBBFB2),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => ref
                      .read(qrisCheckoutProvider.notifier)
                      .checkInvoiceStatusNow(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFFD4A373),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
