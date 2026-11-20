import 'dart:io' show Platform;
import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/indonesia_qris_standee_card.dart';

class SubscriptionActivatedSuccessScreen extends StatefulWidget {
  final String newTier;
  final String invoiceNumber;
  final String amountPaidLabel;
  final DateTime? expiresAt;
  final bool isLifetime;

  const SubscriptionActivatedSuccessScreen({
    super.key,
    required this.newTier,
    required this.invoiceNumber,
    required this.amountPaidLabel,
    this.expiresAt,
    this.isLifetime = true,
  });

  @override
  State<SubscriptionActivatedSuccessScreen> createState() =>
      _SubscriptionActivatedSuccessScreenState();
}

class _SubscriptionActivatedSuccessScreenState
    extends State<SubscriptionActivatedSuccessScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bgCanvas = Color(0xFFF6F3EE);
  static const Color _espresso = Color(0xFF3E2723);
  static const Color _emerald = Color(0xFF059669);
  static const Color _inkDark = Color(0xFF171412);
  static const Color _inkMuted = Color(0xFF6B625B);

  late final ConfettiController _confettiCtrl;
  late final AnimationController _badgeAnimCtrl;
  late final Animation<double> _circleScale;
  late final Animation<double> _rippleScale;
  late final Animation<double> _rippleOpacity;
  late final Animation<double> _checkProgress;

  bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
    _badgeAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _circleScale = CurvedAnimation(
      parent: _badgeAnimCtrl,
      curve: const Interval(0.0, 0.52, curve: Curves.elasticOut),
    );
    _rippleScale = Tween<double>(begin: 0.75, end: 1.55).animate(
      CurvedAnimation(
        parent: _badgeAnimCtrl,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _rippleOpacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(
        parent: _badgeAnimCtrl,
        curve: const Interval(0.20, 0.88, curve: Curves.easeOut),
      ),
    );
    _checkProgress = CurvedAnimation(
      parent: _badgeAnimCtrl,
      curve: const Interval(0.32, 0.90, curve: Curves.easeOutCubic),
    );

    if (_isTestEnv) {
      _badgeAnimCtrl.value = 1.0;
    } else {
      _badgeAnimCtrl.forward();
      _confettiCtrl.play();
    }
  }

  @override
  void dispose() {
    _badgeAnimCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBusiness = widget.newTier.toLowerCase() == 'business';
    final tierTitle =
        isBusiness ? 'Coffee Labs Business' : 'Coffee Labs Pro';
    final expLabel = widget.isLifetime
        ? 'Aktif Penuh (Sekali Bayar)'
        : (widget.expiresAt != null
            ? DateFormat('dd MMM yyyy').format(widget.expiresAt!.toLocal())
            : 'Aktif Penuh');

    return Scaffold(
      backgroundColor: _bgCanvas,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Shopee / Fintech-Grade Animated Checkmark Burst
                      SizedBox(
                        width: 112,
                        height: 112,
                        child: AnimatedBuilder(
                          animation: _badgeAnimCtrl,
                          builder: (_, _) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Transform.scale(
                                  scale: _rippleScale.value,
                                  child: Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _emerald.withValues(
                                        alpha: _rippleOpacity.value,
                                      ),
                                    ),
                                  ),
                                ),
                                Transform.scale(
                                  scale: _circleScale.value.clamp(0.0, 1.25),
                                  child: Container(
                                    width: 82,
                                    height: 82,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF10B981),
                                          Color(0xFF059669),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _emerald.withValues(alpha: 0.32),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: CustomPaint(
                                      painter: _AnimatedCheckmarkPainter(
                                        progress: _checkProgress.value,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Text(
                          'PEMBAYARAN QRIS BERHASIL',
                          style: TextStyle(
                            color: Color(0xFF047857),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Selamat! Akun Anda Kini $tierTitle!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _inkDark,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isBusiness
                            ? 'Seluruh fitur Coffee Labs Pro + Business Roastery Studio, POS Kasir, Kiosk AMOLED AOD, dan Studio QR Meja/Kursi Live Brew 2.0 langsung terbuka!'
                            : 'Seluruh 500+ resep juara dunia, seduh tanpa batas, Toolkit Barista, Pustaka E-Book DRM, Akademi LMS, dan AI Bean Scanner kini langsung terbuka!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _inkMuted,
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Clean White Receipt Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5DDD3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _row(
                              'Merchant',
                              IndonesiaQrisStandeeCard.brandMerchantTitle,
                            ),
                            const Divider(height: 16, color: Color(0xFFF0EAE1)),
                            _row('Nomor Invoice', widget.invoiceNumber),
                            const SizedBox(height: 8),
                            _row('Pembayaran QRIS', widget.amountPaidLabel),
                            const SizedBox(height: 8),
                            _row('Tier Aktif', tierTitle),
                            const SizedBox(height: 8),
                            _row('Aktif Hingga', expLabel),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _espresso,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          icon: const Icon(Icons.check_circle_rounded, size: 19),
                          label: const Text(
                            'Mulai Nikmati Fitur Sekarang',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiCtrl,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Color(0xFF059669),
              Color(0xFFD9232E),
              Color(0xFFD97706),
              Color(0xFF3E2723),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          k,
          style: const TextStyle(
            color: _inkMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            v,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _inkDark,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedCheckmarkPainter extends CustomPainter {
  final double progress;

  const _AnimatedCheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final p1 = Offset(size.width * 0.27, size.height * 0.52);
    final p2 = Offset(size.width * 0.44, size.height * 0.68);
    final p3 = Offset(size.width * 0.74, size.height * 0.35);

    final path = Path()..moveTo(p1.dx, p1.dy);
    if (progress <= 0.45) {
      final t = progress / 0.45;
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * t,
        p1.dy + (p2.dy - p1.dy) * t,
      );
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * t,
        p2.dy + (p3.dy - p2.dy) * t,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedCheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
