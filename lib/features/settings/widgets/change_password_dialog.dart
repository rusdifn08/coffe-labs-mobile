import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/language_service.dart';
import '../../../theme/app_theme.dart';

class ChangePasswordDialog {
  static void show(BuildContext context, AuthUser? currentUser) {
    final isEn = LanguageService.isEnglish;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEn ? 'Changing password requires an active logged-in account.' : 'Fitur ubah password memerlukan akun login aktif.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              const Icon(CupertinoIcons.lock_shield_fill, color: AppTheme.primaryBrown, size: 24),
              const SizedBox(width: 10),
              Text(isEn ? 'Change Password' : 'Ubah Password', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEn
                      ? 'Enter your current password and a new password (min. 6 characters).'
                      : 'Masukkan kata sandi lama dan kata sandi baru minimal 6 karakter.',
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),

                // Password Saat Ini
                TextField(
                  controller: currentPassCtrl,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: isEn ? 'Current Password' : 'Password Saat Ini',
                    filled: true,
                    fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill, size: 18),
                      onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Password Baru
                TextField(
                  controller: newPassCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: isEn ? 'New Password (min. 6)' : 'Password Baru (min. 6)',
                    filled: true,
                    fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill, size: 18),
                      onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Konfirmasi Password Baru
                TextField(
                  controller: confirmPassCtrl,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: isEn ? 'Confirm New Password' : 'Konfirmasi Password Baru',
                    filled: true,
                    fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill, size: 18),
                      onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: Text(isEn ? 'Cancel' : 'Batal', style: const TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final currentPass = currentPassCtrl.text;
                      final newPass = newPassCtrl.text;
                      final confirmPass = confirmPassCtrl.text;

                      if (currentPass.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEn ? 'Please enter current password.' : 'Masukkan password saat ini.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      if (newPass.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEn ? 'New password must be at least 6 characters.' : 'Password baru minimal 6 karakter.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      if (newPass != confirmPass) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEn ? 'Passwords do not match!' : 'Konfirmasi password tidak cocok!'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);
                      final result = await AuthService.changePassword(
                        currentPassword: currentPass,
                        newPassword: newPass,
                      );
                      setDialogState(() => isSubmitting = false);

                      if (dialogCtx.mounted) {
                        Navigator.pop(ctx);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? (isEn ? 'Password update status.' : 'Status update password.')),
                            backgroundColor: result['success'] == true ? Colors.green : Colors.redAccent,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEn ? 'Save New Password' : 'Simpan Password Baru'),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      currentPassCtrl.dispose();
      newPassCtrl.dispose();
      confirmPassCtrl.dispose();
    });
  }
}
