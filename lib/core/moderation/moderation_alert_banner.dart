import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'content_moderation_guard.dart';

/// Komponen umpan balik UI resmi untuk pemblokiran kata terlarang & pelanggaran bahasa Coffee Labs.
class ModerationAlertFeedback {
  ModerationAlertFeedback._();

  /// Menampilkan POP-UP MODAL resmi "Pelanggaran Bahasa" saat konten mengandung kata terlarang
  /// atau saat akun terkena pembatasan otomatis (auto-ban sementara) akibat pelanggaran berulang.
  static Future<void> showViolationDialog(
    BuildContext context,
    ModerationVerdict verdict, {
    ModerationBanStatus? banStatus,
  }) async {
    if (verdict.isAllowed && !(banStatus?.isBanned ?? false)) return;
    HapticFeedback.heavyImpact();

    final status = banStatus ?? verdict.banStatus;
    final isBanned = status?.isBanned ?? false;
    final strikes = status?.strikeCount ?? 1;
    final maxStrikes = ModerationBanStatus.maxStrikesBeforeBan;
    final category = verdict.category ?? 'Kata Kasar & Bahasa Tidak Pantas';
    final title = isBanned
        ? 'Akun Dibatasi Sementara'
        : 'Pelanggaran Bahasa Terdeteksi';
    final bodyMessage = isBanned
        ? 'Anda telah mencapai batas $maxStrikes/$maxStrikes pelanggaran bahasa. '
            'Akses membuat postingan & komentar dibekukan otomatis selama ${status!.formattedRemaining}.'
        : (verdict.userMessage ??
            'Konten Anda mengandung kata terlarang dan TIDAK dipublikasikan. '
                'Harap gunakan bahasa yang sopan dan positif di komunitas Coffee Labs.');

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shield / Ban Icon Badge
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: isBanned
                        ? const Color(0xFF991B1B).withValues(alpha: 0.12)
                        : const Color(0xFFDC2626).withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.shield_slash_fill,
                    color: isBanned
                        ? const Color(0xFF991B1B)
                        : const Color(0xFFDC2626),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F1610),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Category Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(
                    isBanned ? 'AUTO-BAN SEMENTARA • $category' : category,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  bodyMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF4A3B32),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                // Strike Indicator Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isBanned
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFFFED7AA),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isBanned
                                ? CupertinoIcons.lock_fill
                                : CupertinoIcons.exclamationmark_triangle_fill,
                            size: 15,
                            color: isBanned
                                ? const Color(0xFFB91C1C)
                                : const Color(0xFFC2410C),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isBanned
                                ? 'Status Pembatasan: ${status!.formattedRemaining}'
                                : 'Catatan Pelanggaran: $strikes / $maxStrikes',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isBanned
                                  ? const Color(0xFF991B1B)
                                  : const Color(0xFF9A3412),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(maxStrikes, (i) {
                          final active = i < strikes;
                          return Expanded(
                            child: Container(
                              height: 6,
                              margin: EdgeInsets.only(
                                right: i == maxStrikes - 1 ? 0 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        isBanned
                            ? 'Postingan otomatis ditolak selama masa pembatasan berlangsung.'
                            : 'Konten tidak dipublikasikan. $maxStrikes× pelanggaran akan memicu auto-ban sementara pada akun Anda.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7C2D12),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB91C1C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isBanned ? 'Mengerti' : 'Perbaiki Teks',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
  }

  /// Menampilkan peringatan tegas + haptic saat konten diblokir oleh [ContentModerationGuard].
  static void showBlockedSnackBar(
    BuildContext context,
    ModerationVerdict verdict,
  ) {
    if (verdict.isAllowed) return;
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
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
