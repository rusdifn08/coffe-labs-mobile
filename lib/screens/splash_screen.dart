import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/router/app_router.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../services/trial_service.dart';
import '../widgets/splash_brew_animation.dart';

/// Halaman pembuka (Splash Screen) dengan animasi sinematik bertaraf profesional:
/// - Logo emblem modern (bejana laboratorium & biji kopi emas) tanpa lingkaran kaku.
/// - Efek uap aroma melayang, riak ekstraksi emas, dan kilau cahaya dinamis.
/// - Tipografi modern luxury dengan transisi halus deklaratif GoRouter.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _introCtrl;
  late AnimationController _aromaCtrl;

  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _textSlide;
  late Animation<double> _auraPulse;

  @override
  void initState() {
    super.initState();

    // 1. Controller untuk intro reveal (kemunculan awal 1000ms)
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic),
    );

    _fade = CurvedAnimation(parent: _introCtrl, curve: Curves.easeOut);

    _textSlide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    // 2. Controller looping untuk uap aroma & kilau cahaya
    _aromaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _auraPulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _aromaCtrl, curve: Curves.easeInOut),
    );

    _introCtrl.forward();
    _goNext();
  }

  Future<void> _goNext() async {
    // Warm up backend di Render secara senyap di background
    AuthService.warmUpBackend();
    final authUser = await ref.read(authControllerProvider.future);
    final isAuthed = authUser != null || await AuthService.isLoggedIn();
    final isTrial = await TrialService.isTrialMode();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    context.go((isAuthed || isTrial) ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _aromaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.12),
            radius: 1.15,
            colors: [
              Color(0xFF261A13), // Hangat di sekitar logo
              Color(0xFF160E0A), // Espresso gelap
              Color(0xFF0F0A07), // Obsidian pekat di tepian
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_introCtrl, _aromaCtrl]),
            builder: (context, child) {
              return Stack(
                children: [
                  // Ambient warm spotlight di belakang logo
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, -32),
                      child: Container(
                        width: 220 * _auraPulse.value,
                        height: 220 * _auraPulse.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(110),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE5A93C).withValues(alpha: 0.12 * _fade.value),
                              blurRadius: 70,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Konten Hero di Tengah
                  Center(
                    child: FadeTransition(
                      opacity: _fade,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. Logo Emblem Bejana Lab Kopi Modern (Tanpa Lingkaran)
                          ScaleTransition(
                            scale: _scale,
                            child: SizedBox(
                              width: 170,
                              height: 170,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Partikel uap & riak ekstraksi (Custom Painter)
                                  CustomPaint(
                                    size: const Size(170, 170),
                                    painter: SplashAromaPainter(
                                      progress: _aromaCtrl.value,
                                      steamColor: const Color(0xFFF7E7CE),
                                      goldAccent: const Color(0xFFE5A93C),
                                    ),
                                  ),

                                  // Emblem utama dengan efek kilau emas menyapu
                                  ShimmerGlance(
                                    animationValue: _aromaCtrl.value,
                                    child: Image.asset(
                                      'assets/images/coffee_labs_emblem.png',
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        CupertinoIcons.lab_flask_solid,
                                        size: 72,
                                        color: Color(0xFFD4AF37),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 2. Tipografi Judul 'Coffee Labs'
                          Transform.translate(
                            offset: Offset(0, _textSlide.value),
                            child: Column(
                              children: [
                                Text(
                                  'Coffee Labs',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFFFF7ED),
                                    letterSpacing: 2.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                      Shadow(
                                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                                        blurRadius: 18,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // 3. Subtitle 'Master Your Brew' dengan garis emas presisi
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 1,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFD4AF37).withValues(alpha: 0.0),
                                            const Color(0xFFD4AF37).withValues(alpha: 0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        'Master Your Brew',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFE5A93C),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 3.2,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 1,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFD4AF37).withValues(alpha: 0.7),
                                            const Color(0xFFD4AF37).withValues(alpha: 0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Subtle Laboratory Calibrating Indicator di Bawah Layar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: FadeTransition(
                      opacity: _fade,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5A93C).withValues(
                                  alpha: 0.4 + 0.6 * math.sin(_aromaCtrl.value * math.pi),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SPECIALTY BREWING INTELLIGENCE',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.5,
                                color: const Color(0xFF8F857D).withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
