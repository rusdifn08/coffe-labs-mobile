import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Dialog animasi modern untuk menampilkan status pendaftaran berhasil
/// tanpa teks panjang yang membingungkan.
class RegistrationSuccessDialog extends StatefulWidget {
  final String username;
  final String? fullName;
  final VoidCallback onContinue;

  const RegistrationSuccessDialog({
    super.key,
    required this.username,
    this.fullName,
    required this.onContinue,
  });

  @override
  State<RegistrationSuccessDialog> createState() => _RegistrationSuccessDialogState();
}

class _RegistrationSuccessDialogState extends State<RegistrationSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleBadge;
  late Animation<double> _glowScale;
  late Animation<double> _fadeContent;
  late Animation<Offset> _slideContent;

  Timer? _autoRedirectTimer;
  bool _hasContinued = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Animasi memantul (elastic bounce) untuk badge centang
    _scaleBadge = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
      ),
    );

    // Animasi denyut lingkaran cahaya (glow)
    _glowScale = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOutQuad),
      ),
    );

    // Fade dan slide teks judul & tombol
    _fadeContent = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.4, 0.95, curve: Curves.easeIn),
      ),
    );

    _slideContent = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.4, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _animCtrl.forward();

    // Auto-lanjut setelah 2.4 detik agar pengguna bisa langsung masuk
    _autoRedirectTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        _proceed();
      }
    });
  }

  void _proceed() {
    if (_hasContinued) return;
    _hasContinued = true;
    _autoRedirectTimer?.cancel();
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    widget.onContinue();
  }

  @override
  void dispose() {
    _autoRedirectTimer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (widget.fullName != null && widget.fullName!.trim().isNotEmpty)
        ? widget.fullName!.trim()
        : widget.username;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      elevation: 0,
      child: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge Animasi Centang Sukses
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Lingkaran Glow Berkedip Lembut
                    AnimatedBuilder(
                      animation: _glowScale,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _glowScale.value,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                            ),
                          ),
                        );
                      },
                    ),

                    // Badge Utama Hijau Zamrud dengan Centang
                    ScaleTransition(
                      scale: _scaleBadge,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF43A047),
                              Color(0xFF1B5E20),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                    ),

                    // Efek Sparkle Kilau di Sudut Kanan Atas
                    Positioned(
                      top: 6,
                      right: 12,
                      child: ScaleTransition(
                        scale: _scaleBadge,
                        child: const Icon(
                          CupertinoIcons.sparkles,
                          color: AppTheme.accentGold,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Teks Ucapan Selamat & Status Pendaftaran
              SlideTransition(
                position: _slideContent,
                child: FadeTransition(
                  opacity: _fadeContent,
                  child: Column(
                    children: [
                      const Text(
                        'Pendaftaran Berhasil!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1C1A17),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selamat datang, $displayName!\nAkun barista Anda aktif dan siap menyeduh.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppTheme.textMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Tombol Aksi Cepat "Masuk Sekarang"
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _proceed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Mulai Menyeduh Sekarang',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(CupertinoIcons.arrow_right, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
