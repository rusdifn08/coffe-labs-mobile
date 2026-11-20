import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AuthLoginForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool isSuccess;
  final VoidCallback onLogin;
  final VoidCallback onSwitchToSignUp;

  const AuthLoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.isLoading,
    this.isSuccess = false,
    required this.onLogin,
    required this.onSwitchToSignUp,
  });

  @override
  State<AuthLoginForm> createState() => _AuthLoginFormState();
}

class _AuthLoginFormState extends State<AuthLoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.isLoading || widget.isSuccess;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Login',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 6),
        const Text(
          'Masukkan akun Anda untuk melanjutkan.',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 20),

        // Username Field
        TextField(
          controller: widget.usernameController,
          enabled: !isLocked,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'Masukkan username',
            prefixIcon: const Icon(CupertinoIcons.person_fill, color: AppTheme.primaryBrown, size: 20),
            filled: true,
            fillColor: isLocked
                ? Colors.grey.shade100
                : AppTheme.bgCream.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password Field
        TextField(
          controller: widget.passwordController,
          enabled: !isLocked,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!isLocked) widget.onLogin();
          },
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(CupertinoIcons.lock_fill, color: AppTheme.primaryBrown, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
                color: AppTheme.textMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: isLocked
                ? Colors.grey.shade100
                : AppTheme.bgCream.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Tombol Login dengan Transisi & Efek Animasi (tanpa teks saat loading/sukses)
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              if (widget.isSuccess)
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                )
              else if (widget.isLoading)
                BoxShadow(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.22),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLocked ? null : widget.onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isSuccess
                  ? const Color(0xFF10B981)
                  : AppTheme.primaryBrown,
              disabledBackgroundColor: widget.isSuccess
                  ? const Color(0xFF10B981)
                  : AppTheme.primaryBrown.withValues(alpha: 0.88),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: widget.isSuccess
                  ? const SizedBox(
                      key: ValueKey('success'),
                      height: 22,
                      child: Center(
                        child: Icon(
                          CupertinoIcons.checkmark_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    )
                  : widget.isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          key: ValueKey('idle'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.arrow_right_circle_fill, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Teks "Belum punya akun? Sign Up" dengan Sign Up berwarna biru
        Center(
          child: InkWell(
            onTap: isLocked ? null : widget.onSwitchToSignUp,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: RichText(
                text: const TextSpan(
                  text: 'Belum punya akun? ',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF1E88E5),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
