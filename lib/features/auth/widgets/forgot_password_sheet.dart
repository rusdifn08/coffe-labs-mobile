import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';

typedef RequestPasswordResetFn = Future<Map<String, dynamic>> Function({
  required String identifier,
});

typedef ConfirmPasswordResetFn = Future<Map<String, dynamic>> Function({
  required String identifier,
  required String code,
  required String newPassword,
});

/// Bottom Sheet 2 langkah untuk fitur Lupa Password & Reset via Kode Email 6 Digit.
class ForgotPasswordSheet extends StatefulWidget {
  final String initialIdentifier;
  final ValueChanged<String>? onResetSuccess;
  final RequestPasswordResetFn? requestResetFn;
  final ConfirmPasswordResetFn? confirmResetFn;

  const ForgotPasswordSheet({
    super.key,
    this.initialIdentifier = '',
    this.onResetSuccess,
    this.requestResetFn,
    this.confirmResetFn,
  });

  static Future<void> show(
    BuildContext context, {
    String initialIdentifier = '',
    ValueChanged<String>? onResetSuccess,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ForgotPasswordSheet(
        initialIdentifier: initialIdentifier,
        onResetSuccess: onResetSuccess,
      ),
    );
  }

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  late final TextEditingController _identifierCtrl;
  final TextEditingController _codeCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  int _step = 1; // 1 = minta kode, 2 = verifikasi kode + password baru
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _maskedEmail;
  String? _errorMsg;
  String? _infoMsg;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _identifierCtrl = TextEditingController(text: widget.initialIdentifier);
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _identifierCtrl.dispose();
    _codeCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _startCooldown([int seconds = 60]) {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _handleRequestCode() async {
    final identifier = _identifierCtrl.text.trim();
    if (identifier.isEmpty) {
      setState(() => _errorMsg = 'Masukkan email atau username akun Anda.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _infoMsg = null;
    });

    final fn = widget.requestResetFn ?? AuthService.requestPasswordReset;
    final res = await fn(identifier: identifier);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      HapticFeedback.lightImpact();
      setState(() {
        _step = 2;
        _maskedEmail = res['maskedEmail']?.toString();
        _infoMsg = res['message']?.toString() ??
            'Kode reset 6 digit telah dikirim ke email Anda.';
        _errorMsg = null;
      });
      _startCooldown(60);
    } else {
      setState(() {
        _errorMsg = res['message']?.toString() ?? 'Gagal mengirim kode reset.';
      });
    }
  }

  Future<void> _handleConfirmReset() async {
    final identifier = _identifierCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final newPass = _newPasswordCtrl.text;
    final confirmPass = _confirmPasswordCtrl.text;

    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _errorMsg = 'Masukkan 6 digit angka kode reset dari email Anda.');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _errorMsg = 'Password baru minimal 6 karakter.');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _errorMsg = 'Konfirmasi password baru tidak cocok.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final fn = widget.confirmResetFn ?? AuthService.confirmPasswordReset;
    final res = await fn(
      identifier: identifier,
      code: code,
      newPassword: newPass,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      HapticFeedback.mediumImpact();
      final successMsg = res['message']?.toString() ??
          'Password berhasil direset! Silakan login dengan password baru.';
      final messenger = ScaffoldMessenger.maybeOf(context);
      widget.onResetSuccess?.call(identifier);
      Navigator.of(context).pop();
      messenger?.showSnackBar(
        SnackBar(
          content: Text(successMsg),
          backgroundColor: const Color(0xFF15803D),
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      setState(() {
        _errorMsg = res['message']?.toString() ?? 'Gagal mereset password.';
      });
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.primaryBrown, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppTheme.bgCream.withValues(alpha: 0.65),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.fromLTRB(24, 14, 24, bottomInset + 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCream,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _step == 1
                          ? CupertinoIcons.mail_solid
                          : CupertinoIcons.lock_rotation_open,
                      color: AppTheme.primaryBrown,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _step == 1 ? 'Lupa Password?' : 'Reset Password via Email',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _step == 1
                              ? 'Langkah 1 dari 2 • Kirim kode ke email terdaftar'
                              : 'Langkah 2 dari 2 • Masukkan kode 6 digit & password baru',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppTheme.textMuted),
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_infoMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF15803D), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _maskedEmail != null
                              ? 'Kode reset 6 digit dikirim ke $_maskedEmail (berlaku 15 menit). Cek Inbox atau folder Spam.'
                              : _infoMsg!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMsg!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (_step == 1) ...[
                const Text(
                  'Masukkan alamat email atau username akun Coffee Labs Anda. Kode reset 6 digit akan dikirim langsung ke kotak masuk email Anda.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.45),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _identifierCtrl,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isLoading) _handleRequestCode();
                  },
                  decoration: _fieldDecoration(
                    label: 'Email atau Username',
                    hint: 'nama@gmail.com atau username',
                    icon: CupertinoIcons.mail_solid,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleRequestCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        )
                      : const Icon(CupertinoIcons.paperplane_fill, size: 18),
                  label: Text(
                    _isLoading ? 'Mengirim Kode...' : 'Kirim Kode Reset ke Email',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_identifierCtrl.text.trim().isEmpty) {
                            setState(() => _errorMsg = 'Isi email/username dulu sebelum memasukkan kode.');
                            return;
                          }
                          setState(() {
                            _step = 2;
                            _errorMsg = null;
                          });
                        },
                  child: const Text(
                    'Sudah punya kode 6 digit? Masukkan di sini',
                    style: TextStyle(fontSize: 12.5, color: AppTheme.primaryBrown, fontWeight: FontWeight.w600),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _codeCtrl,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                    color: AppTheme.textDark,
                  ),
                  decoration: _fieldDecoration(
                    label: 'Kode Reset 6 Digit',
                    hint: '000000',
                    icon: CupertinoIcons.number_square_fill,
                  ).copyWith(counterText: ''),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _newPasswordCtrl,
                  enabled: !_isLoading,
                  obscureText: _obscureNew,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration(
                    label: 'Password Baru (min. 6 karakter)',
                    icon: CupertinoIcons.lock_fill,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _confirmPasswordCtrl,
                  enabled: !_isLoading,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isLoading) _handleConfirmReset();
                  },
                  decoration: _fieldDecoration(
                    label: 'Konfirmasi Password Baru',
                    icon: CupertinoIcons.lock_shield_fill,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleConfirmReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        )
                      : const Icon(CupertinoIcons.checkmark_shield_fill, size: 18),
                  label: Text(
                    _isLoading ? 'Menyimpan...' : 'Simpan Password Baru',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                                _step = 1;
                                _errorMsg = null;
                              }),
                      icon: const Icon(CupertinoIcons.arrow_left, size: 15),
                      label: const Text('Ganti Email', style: TextStyle(fontSize: 12.5)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textMuted,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    TextButton(
                      onPressed: (_isLoading || _resendCooldown > 0) ? null : _handleRequestCode,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        _resendCooldown > 0
                            ? 'Kirim Ulang (${_resendCooldown}d)'
                            : 'Kirim Ulang Kode',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: _resendCooldown > 0
                              ? AppTheme.textMuted
                              : AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
