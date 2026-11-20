import 'dart:io' show Platform;
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    extends State<SubscriptionActivatedSuccessScreen> {
  late final ConfettiController _confettiCtrl;

  bool get _isTestEnv =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
    if (!_isTestEnv) {
      _confettiCtrl.play();
    }
  }

  @override
  void dispose() {
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
      backgroundColor: const Color(0xFF12100E),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF22C55E).withValues(alpha: 0.18),
                      border: Border.all(
                        color: const Color(0xFF22C55E),
                        width: 2.5,
                      ),
                    ),
                    child: Icon(
                      isBusiness
                          ? Icons.storefront_rounded
                          : CupertinoIcons.sparkles,
                      color: const Color(0xFF22C55E),
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Selamat! Akun Anda Kini $tierTitle!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF9F5EE),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isBusiness
                        ? 'Seluruh fitur Coffee Labs Pro + Business Roastery Studio, POS Kasir, Kiosk AMOLED AOD, dan Studio QR Meja/Kursi Live Brew 2.0 langsung terbuka tanpa perlu login ulang!'
                        : 'Seluruh 500+ resep juara dunia, seduh tanpa batas, Toolkit Barista 21 fitur, Akademi LMS, AI Bean Scanner, dan pengalaman bebas iklan kini langsung terbuka!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFCBBFB2),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1714),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFD4A373).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      children: [
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
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A373),
                        foregroundColor: const Color(0xFF12100E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 19),
                      label: const Text(
                        'Mulai Nikmati Fitur Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiCtrl,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Color(0xFFD4A373),
              Color(0xFF22C55E),
              Color(0xFFF59E0B),
              Color(0xFFF9F5EE),
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
            color: Color(0xFF9C8F82),
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
              color: Color(0xFFF9F5EE),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
