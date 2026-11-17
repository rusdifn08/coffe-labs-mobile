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

/// Halaman pembuka (Splash Screen) Coffee Labs beranimasi koreografis profesional:
/// - Kanvas Warm Cream Atelier (#FFFDF9 -> #F6EDE0 -> #EADBC6) selaras ikon & tema terang resmi.
/// - Emblem orbital-atom & Chemex transparan bebas latar putih dengan kilau emas menyapu.
/// - Cincin telemetri orbital & partikel satelit berputar halus di belakang emblem.
/// - Staggered typography entrance menuju transisi rute GoRouter deklaratif.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _introCtrl;
  late AnimationController _aromaCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<double> _textSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _auraPulse;

  @override
  void initState() {
    super.initState();

    // 1. Koreografi masuk bertahap (1150ms)
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );

    _logoFade = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.0, 0.50, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.74, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.0, 0.78, curve: Curves.easeOutBack),
      ),
    );

    _logoRotate = Tween<double>(begin: -0.10, end: 0.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.0, 0.74, curve: Curves.easeOutQuart),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.32, 0.86, curve: Curves.easeOut),
    );

    _textSlide = Tween<double>(begin: 22.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.32, 0.90, curve: Curves.easeOutQuart),
      ),
    );

    _subtitleFade = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.52, 1.0, curve: Curves.easeOut),
    );

    // 2. Siklus ambien orbital, uap aroma & kilau emas berkelanjutan
    _aromaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _auraPulse = Tween<double>(begin: 0.90, end: 1.12).animate(
      CurvedAnimation(parent: _aromaCtrl, curve: Curves.easeInOut),
    );

    _introCtrl.forward();
    _goNext();
  }

  Future<void> _goNext() async {
    // Warm up backend & sinkronkan Trial Policy secara senyap tanpa menunda UI
    AuthService.warmUpBackend();
    TrialService.getPolicy(refreshFromBackend: true).catchError(
      (_) => TrialService.currentPolicySync,
    );
    AuthUser? authUser;
    try {
      authUser = await ref
          .read(authControllerProvider.future)
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
    final isAuthed = authUser != null || await AuthService.isLoggedIn();
    final isTrial = await TrialService.isTrialMode();
    await Future.delayed(const Duration(milliseconds: 1450));
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
            center: Alignment(0.0, -0.10),
            radius: 1.15,
            colors: [
              Color(0xFFFFFCF7), // Sorotan krem hangat di belakang logo
              Color(0xFFF6EDE0), // Krem signature Coffee Labs
              Color(0xFFE9DAC4), // Parchment hangat di tepian
            ],
            stops: [0.0, 0.56, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_introCtrl, _aromaCtrl]),
            builder: (context, child) {
              return Stack(
                children: [
                  // Sorotan ambien hangat di belakang logo transparan
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, -34),
                      child: Container(
                        width: 210 * _auraPulse.value,
                        height: 210 * _auraPulse.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.16 * _logoFade.value),
                              blurRadius: 68,
                              spreadRadius: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Konten Hero di Tengah
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 1. Panggung Emblem Orbital & Uap Kopi Transparan
                        SizedBox(
                          width: 216,
                          height: 216,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(216, 216),
                                painter: SplashOrbitalTelemetryPainter(
                                  introProgress: _introCtrl.value,
                                  loopProgress: _aromaCtrl.value,
                                  espressoColor: const Color(0xFF3D2313),
                                  goldAccent: const Color(0xFFC8922E),
                                  sageAccent: const Color(0xFF6D7B61),
                                ),
                              ),
                              CustomPaint(
                                size: const Size(216, 216),
                                painter: SplashAromaPainter(
                                  progress: _aromaCtrl.value,
                                  steamColor: const Color(0xFF9A7B4F),
                                  goldAccent: const Color(0xFFC8922E),
                                ),
                              ),
                              FadeTransition(
                                opacity: _logoFade,
                                child: Transform.rotate(
                                  angle: _logoRotate.value,
                                  child: Transform.scale(
                                    scale: _logoScale.value,
                                    child: ShimmerGlance(
                                      animationValue: _aromaCtrl.value,
                                      child: Image.asset(
                                        'assets/images/coffee_labs_emblem.png',
                                        width: 152,
                                        height: 152,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          CupertinoIcons.lab_flask_solid,
                                          size: 72,
                                          color: Color(0xFF6B4423),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 2. Tipografi Judul 'Coffee Labs' Espresso Modern
                        FadeTransition(
                          opacity: _textFade,
                          child: Transform.translate(
                            offset: Offset(0, _textSlide.value),
                            child: Column(
                              children: [
                                Text(
                                  'Coffee Labs',
                                  style: GoogleFonts.poppins(
                                    fontSize: 33,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF3D2313),
                                    letterSpacing: 1.4,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xFF3D2313).withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // 3. Subtitle 'Master Your Brew' dengan garis gradien emas
                                FadeTransition(
                                  opacity: _subtitleFade,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 1.2,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFFC8922E).withValues(alpha: 0.0),
                                              const Color(0xFFC8922E).withValues(alpha: 0.8),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          'MASTER YOUR BREW',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF8C6220),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 3.0,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 28,
                                        height: 1.2,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFFC8922E).withValues(alpha: 0.8),
                                              const Color(0xFFC8922E).withValues(alpha: 0.0),
                                            ],
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
                      ],
                    ),
                  ),

                  // 4. Indikator Kalibrasi Presisi di Bagian Bawah
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 28,
                    child: FadeTransition(
                      opacity: _subtitleFade,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 112,
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B4423).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _introCtrl.value.clamp(0.08, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6D7B61),
                                      Color(0xFFC8922E),
                                      Color(0xFF6B4423),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6D7B61).withValues(
                                    alpha: 0.45 + 0.55 * math.sin(_aromaCtrl.value * math.pi),
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
                                  letterSpacing: 2.3,
                                  color: const Color(0xFF7A6A5C),
                                ),
                              ),
                            ],
                          ),
                        ],
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
