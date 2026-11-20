import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/qris_billing_models.dart';
import '../controllers/qris_checkout_controller.dart';
import '../services/qris_image_saver_service.dart';
import '../widgets/indonesia_qris_standee_card.dart';
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
  static const Color _bgCanvas = Color(0xFFF6F3EE);
  static const Color _espresso = Color(0xFF3E2723);
  static const Color _inkDark = Color(0xFF171412);
  static const Color _inkMuted = Color(0xFF6B625B);
  static const Color _emerald = Color(0xFF059669);
  static const Color _qrisRed = Color(0xFFD9232E);

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
        baseFileName: 'QRIS_CoffeeLabsIndonesia_${invoice.totalPayableIdr}',
        merchantName: IndonesiaQrisStandeeCard.brandMerchantTitle,
        formattedAmount: invoice.formattedTotal,
      );
      if (!mounted) return;
      if (res.success) HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          backgroundColor: res.success ? _emerald : _qrisRed,
          content: Text(res.displayMessage),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _qrisRed,
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
        baseFileName: 'QRIS_CoffeeLabsIndonesia_${invoice.totalPayableIdr}',
        shareText:
            'Pembayaran QRIS ${IndonesiaQrisStandeeCard.brandMerchantTitle} — ${invoice.isBusiness ? 'Coffee Labs Business' : 'Coffee Labs Pro'} sebesar ${invoice.formattedTotal} (${invoice.invoiceNumber}).',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _qrisRed,
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
    final detected =
        await ref.read(qrisCheckoutProvider.notifier).checkInvoiceStatusNow();
    if (detected || !mounted) return;

    final rrnCtrl = TextEditingController();
    Uint8List? pickedBytes;
    String? pickedName;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isVerifying =
                ref.watch(qrisCheckoutProvider).isVerifyingPayment;
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  MediaQuery.of(ctx).viewInsets.bottom + 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6CEC4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.verified_rounded,
                            color: _emerald,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Konfirmasi Pembayaran ${invoice.formattedTotal}',
                                style: const TextStyle(
                                  color: _inkDark,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Text(
                                IndonesiaQrisStandeeCard.brandMerchantTitle,
                                style: TextStyle(
                                  color: _inkMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sudah menyelesaikan transfer QRIS sebesar ${invoice.formattedTotal}? Masukkan Nomor RRN struk (opsional) atau lampirkan bukti bayar untuk langsung mengaktifkan ${invoice.isBusiness ? 'Coffee Labs Business' : 'Coffee Labs Pro'}.',
                      style: const TextStyle(
                        color: _inkMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: rrnCtrl,
                      style: const TextStyle(
                        color: _inkDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Nomor RRN / Referensi QRIS (Opsional)',
                        hintText: 'Contoh: 405375872',
                        labelStyle: const TextStyle(
                          color: _espresso,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        hintStyle: const TextStyle(
                          color: Color(0xFFA09890),
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: _bgCanvas,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0D7CC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _espresso, width: 1.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _espresso,
                          side: const BorderSide(color: Color(0xFFD6C9BA)),
                          backgroundColor: const Color(0xFFFAF8F5),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                          size: 17,
                          color: pickedBytes != null ? _emerald : _espresso,
                        ),
                        label: Text(
                          pickedName != null
                              ? 'Struk Terlampir ($pickedName)'
                              : 'Lampirkan Struk Pembayaran (Opsional)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _emerald,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
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
                                      backgroundColor: _qrisRed,
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
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.verified_rounded, size: 18),
                        label: Text(
                          isVerifying
                              ? 'Memverifikasi Pembayaran...'
                              : 'Konfirmasi & Aktifkan Lisensi Sekarang',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 420),
            pageBuilder: (_, _, _) => SubscriptionActivatedSuccessScreen(
              newTier: next.confirmedTier!,
              invoiceNumber: inv.invoiceNumber,
              amountPaidLabel: inv.formattedTotal,
              expiresAt: next.confirmedExpiresAt,
              isLifetime: inv.isLifetime,
            ),
            transitionsBuilder: (_, animation, _, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    });

    final state = ref.watch(qrisCheckoutProvider);
    final invoice = state.activeInvoice ?? widget.initialInvoice;

    return Scaffold(
      backgroundColor: _bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _inkDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEAE3DA)),
        ),
        iconTheme: const IconThemeData(color: _inkDark),
        title: const Text(
          'Pembayaran QRIS',
          style: TextStyle(
            color: _inkDark,
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
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
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: urgent
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFFFF8EB),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: urgent
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFE7C68E),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.timer,
                          size: 12.5,
                          color: urgent ? _qrisRed : const Color(0xFF9A5B13),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatCountdown(sec),
                          style: TextStyle(
                            color: urgent ? _qrisRed : const Color(0xFF78350F),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            fontFeatures: const [FontFeature.tabularFigures()],
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
            children: [
              // 1. Clean Plan & Invoice Summary Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFE7E0D6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EFE6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        invoice.isBusiness
                            ? Icons.storefront_rounded
                            : CupertinoIcons.sparkles,
                        color: _espresso,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        invoice.isBusiness
                            ? 'Coffee Labs Business • Sekali Bayar'
                            : 'Coffee Labs Pro • Sekali Bayar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _inkDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE7DFD4)),
                      ),
                      child: Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          color: _inkMuted,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 2. Official Indonesian QRIS Standee Card (RepaintBoundary 3x DPI)
              RepaintBoundary(
                key: _qrisCardKey,
                child: IndonesiaQrisStandeeCard(invoice: invoice),
              ),
              const SizedBox(height: 12),

              // 3. Action Row 1: Save QRIS Standee Image + Share
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _espresso,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _savingGallery
                            ? null
                            : () => _saveQrisCardToDevice(invoice),
                        icon: _savingGallery
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.download_rounded, size: 17),
                        label: const Text(
                          'Simpan Gambar QRIS ke Galeri',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _espresso,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFD5C8B9)),
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          _sharingImage ? null : () => _shareQrisCard(invoice),
                      child: _sharingImage
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _espresso,
                              ),
                            )
                          : const Icon(CupertinoIcons.share, size: 17),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 4. Action Row 2: Instant Verification & Activation CTA
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _emerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
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
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.verified_rounded, size: 18),
                  label: Text(
                    state.isVerifyingPayment
                        ? 'Memverifikasi Pembayaran...'
                        : 'Sudah Bayar? Verifikasi & Aktifkan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),

              // 5. Live Auto-Detection Status Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: invoice.isExpired
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: invoice.isExpired
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFA7F3D0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: invoice.isExpired ? _qrisRed : _emerald,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        invoice.isExpired
                            ? 'QRIS kedaluwarsa. Silakan buat kode QRIS baru.'
                            : 'Deteksi pembayaran otomatis aktif • Scan via BCA, Livin\', GoPay, OVO, DANA',
                        style: TextStyle(
                          color: invoice.isExpired
                              ? const Color(0xFF991B1B)
                              : const Color(0xFF065F46),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => ref
                          .read(qrisCheckoutProvider.notifier)
                          .checkInvoiceStatusNow(),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: invoice.isExpired ? _qrisRed : _emerald,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
