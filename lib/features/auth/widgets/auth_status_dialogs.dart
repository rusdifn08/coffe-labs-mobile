import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'registration_success_dialog.dart';

class AuthStatusDialogs {
  static void showPendingApproval({
    required BuildContext context,
    required String username,
    required VoidCallback onEnterTrial,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.clock_fill, color: Colors.amber, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Menunggu Persetujuan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.textDark),
              ),
            ),
          ],
        ),
        content: Text(
          "Akun '$username' berhasil terdaftar, namun sedang menunggu persetujuan (Accept) dari Admin rusdifn08.\n\nAnda dapat menggunakan 'Mode Trial' terlebih dahulu selagi menunggu akun di-accept oleh Admin.",
          style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onEnterTrial();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Gunakan Trial Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static void showDeclined(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.xmark_circle_fill, color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Text('Akun Ditolak', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
        content: const Text(
          'Pendaftaran akun Anda telah ditolak oleh Admin. Silakan hubungi admin rusdifn08 untuk informasi lebih lanjut.',
          style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti', style: TextStyle(color: AppTheme.primaryBrown)),
          ),
        ],
      ),
    );
  }

  static void showRegistrationSuccess({
    required BuildContext context,
    required String username,
    String? fullName,
    required VoidCallback onContinue,
    VoidCallback? onGoToLogin,
    VoidCallback? onEnterTrial,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RegistrationSuccessDialog(
        username: username,
        fullName: fullName,
        onContinue: onContinue,
      ),
    );
  }
}
