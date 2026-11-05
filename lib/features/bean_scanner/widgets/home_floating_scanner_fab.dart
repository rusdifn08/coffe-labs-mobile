import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'smart_bean_camera_popup_modal.dart';

/// Floating Action Button kamera mengambang di pojok kanan bawah Home Screen.
/// Dirancang untuk memudahkan barista memindai kemasan biji kopi (AI Vision & Spatial OCR)
/// kapan saja saat menjelajahi feed beranda.
class HomeFloatingScannerFab extends StatelessWidget {
  final bool animate;

  const HomeFloatingScannerFab({
    super.key,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

    Widget button = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C3A21), Color(0xFF382315)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD4AF37),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C3A21).withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            SmartBeanCameraPopupModal.show(context);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.center_focus_strong_rounded,
                color: Color(0xFFF9F5EE),
                size: 26,
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF382315), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                        blurRadius: 4,
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

    if (animate && !isTest) {
      button = button
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.06, 1.06), duration: 2000.ms);
    }

    return Tooltip(
      message: 'Scan Kemasan Kopi (AI Vision)',
      child: button,
    );
  }
}
