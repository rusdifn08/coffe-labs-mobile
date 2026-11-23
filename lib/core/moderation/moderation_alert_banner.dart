import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'content_moderation_guard.dart';

/// Komponen umpan balik UI resmi untuk pemblokiran kata kasar multibahasa Coffee Labs.
class ModerationAlertFeedback {
  ModerationAlertFeedback._();

  /// Menampilkan peringatan tegas + haptic saat konten diblokir oleh [ContentModerationGuard].
  static void showBlockedSnackBar(
    BuildContext context,
    ModerationVerdict verdict,
  ) {
    if (verdict.isAllowed) return;
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB91C1C),
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(
                CupertinoIcons.shield_slash_fill,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  verdict.userMessage ??
                      'Konten mengandung kata kasar dan diblokir oleh sistem moderasi Coffee Labs.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

/// Banner peringatan inline (khusus untuk modal bottom sheet & dialog agar selalu terlihat di atas keyboard).
class ModerationInlineWarningBanner extends StatelessWidget {
  final String message;

  const ModerationInlineWarningBanner({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              CupertinoIcons.shield_slash_fill,
              color: Color(0xFFB91C1C),
              size: 18,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
