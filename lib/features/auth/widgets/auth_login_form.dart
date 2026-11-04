import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AuthLoginForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onSwitchToSignUp;

  const AuthLoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.isLoading,
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
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'Masukkan username',
            prefixIcon: const Icon(CupertinoIcons.person_fill, color: AppTheme.primaryBrown, size: 20),
            filled: true,
            fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
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
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.onLogin(),
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
            fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Tombol Login
        ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBrown,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
        if (widget.isLoading) ...[
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBrown),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Menghubungkan ke Cloud Server (Render)...',
                  style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),

        // Teks "Belum punya akun? Sign Up" dengan Sign Up berwarna biru
        Center(
          child: InkWell(
            onTap: widget.onSwitchToSignUp,
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
                        color: Color(0xFF1E88E5), // Warna biru sesuai permintaan
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
