import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'smart_bean_camera_popup_modal.dart';

class HomeHeaderScannerButton extends StatelessWidget {
  final bool compact;
  final bool animate;

  const HomeHeaderScannerButton({
    super.key,
    this.compact = false,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF5C3A21),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5C3A21).withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          tooltip: 'Scan Kemasan Kopi (AI Vision)',
          icon: const Icon(Icons.center_focus_strong_rounded, size: 18, color: Color(0xFFF9F5EE)),
          onPressed: () => SmartBeanCameraPopupModal.show(context),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C3A21), Color(0xFF382315)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C3A21).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => SmartBeanCameraPopupModal.show(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                () {
                  final iconBox = Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F5EE).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.center_focus_strong_rounded,
                      color: Color(0xFFF9F5EE),
                      size: 24,
                    ),
                  );
                  final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
                  if (animate && !isTest) {
                    return iconBox
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.08, 1.08), duration: 1800.ms);
                  }
                  return iconBox;
                }(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Scan Kemasan Kopi (AI Vision)',
                            style: TextStyle(
                              color: Color(0xFFF9F5EE),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AI OCR',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Foto 1x kemasan: kenali roastery, varietas, proses & resep V60',
                        style: TextStyle(
                          color: Color(0xFFD8C7B8),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: Color(0xFFF9F5EE),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
