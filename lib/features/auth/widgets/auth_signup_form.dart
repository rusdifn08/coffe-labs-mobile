import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../services/profile_service.dart';
import '../../../theme/app_theme.dart';

class AuthSignUpForm extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final String? selectedAvatar;
  final bool isLoading;
  final VoidCallback onPickAvatar;
  final VoidCallback onRegister;
  final VoidCallback onBackToLogin;

  const AuthSignUpForm({
    super.key,
    required this.fullNameController,
    required this.usernameController,
    required this.passwordController,
    required this.selectedAvatar,
    required this.isLoading,
    required this.onPickAvatar,
    required this.onRegister,
    required this.onBackToLogin,
  });

  @override
  State<AuthSignUpForm> createState() => _AuthSignUpFormState();
}

class _AuthSignUpFormState extends State<AuthSignUpForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.arrow_left, color: AppTheme.primaryBrown),
              onPressed: widget.onBackToLogin,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            const Text(
              'Sign Up',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Daftar akun barista baru Anda.',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 18),

        // Avatar Preview & Picker
        Center(
          child: GestureDetector(
            onTap: widget.onPickAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.bgCream,
                  backgroundImage: ProfileService.getImageProvider(widget.selectedAvatar),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBrown,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: TextButton(
            onPressed: widget.onPickAvatar,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text('Pilih Karakter Avatar', style: TextStyle(fontSize: 12, color: AppTheme.primaryBrown, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),

        // Full Name Field
        TextField(
          controller: widget.fullNameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Nama Lengkap',
            hintText: 'Misal: Rusdi Barista',
            prefixIcon: const Icon(CupertinoIcons.person_badge_plus, color: AppTheme.primaryBrown, size: 20),
            filled: true,
            fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Username Field
        TextField(
          controller: widget.usernameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'huruf kecil tanpa spasi',
            prefixIcon: const Icon(CupertinoIcons.at, color: AppTheme.primaryBrown, size: 20),
            filled: true,
            fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Password Field
        TextField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.onRegister(),
          decoration: InputDecoration(
            labelText: 'Password (min. 6 karakter)',
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
        const SizedBox(height: 20),

        // Tombol Sign Up
        ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onRegister,
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
                  'Daftar Sekarang',
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
                  'Mendaftarkan ke Cloud Server (Render)...',
                  style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),

        // Tombol kembali ke Login
        Center(
          child: InkWell(
            onTap: widget.onBackToLogin,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Sudah punya akun? Login',
                style: TextStyle(
                  color: Color(0xFF1E88E5), // Warna biru
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
