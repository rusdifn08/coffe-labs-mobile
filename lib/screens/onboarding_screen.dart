import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/router/app_router.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/widgets/auth_error_banner.dart';
import '../features/auth/widgets/auth_header.dart';
import '../features/auth/widgets/auth_login_form.dart';
import '../features/auth/widgets/auth_signup_form.dart';
import '../features/auth/widgets/auth_status_dialogs.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/trial_service.dart';
import '../theme/app_theme.dart';

/// Halaman Otentikasi & Onboarding menggunakan ConsumerStatefulWidget + GoRouter.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _isSignUpMode = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  // Login Controllers
  final TextEditingController _loginUsernameCtrl = TextEditingController();
  final TextEditingController _loginPasswordCtrl = TextEditingController();

  // Register Controllers
  final TextEditingController _regUsernameCtrl = TextEditingController();
  final TextEditingController _regFullNameCtrl = TextEditingController();
  final TextEditingController _regPasswordCtrl = TextEditingController();
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    AuthService.warmUpBackend();
    _loadDefaultAvatar();
  }

  Future<void> _loadDefaultAvatar() async {
    final avatar = await ProfileService.getDefaultAvatar();
    if (mounted) {
      setState(() {
        _selectedAvatar = avatar;
      });
    }
  }

  @override
  void dispose() {
    _loginUsernameCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regFullNameCtrl.dispose();
    _regPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    await ProfileService.showAvatarPickerDialog(
      context: context,
      currentPath: _selectedAvatar,
      onSelected: (newPath) {
        setState(() {
          _selectedAvatar = newPath;
        });
      },
    );
  }

  Future<void> _handleLogin() async {
    final username = _loginUsernameCtrl.text.trim();
    final password = _loginPasswordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Harap isi username dan password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSuccess = false;
      _errorMessage = null;
    });

    final result = await AuthService.login(username: username, password: password);
    ref.invalidate(authControllerProvider);

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
      HapticFeedback.mediumImpact();

      // Animasi transisi lembut: berikan waktu sejenak agar pengguna melihat badge sukses
      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.user?.isAdmin == true
                ? '👑 Login berhasil sebagai Admin Rusdi!'
                : 'Selamat datang kembali, ${result.user?.fullName}!',
          ),
          backgroundColor: AppTheme.primaryBrown,
          duration: const Duration(seconds: 2),
        ),
      );
      context.go(AppRoutes.home);
    } else {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
      });
      if (result.status == 'pending') {
        AuthStatusDialogs.showPendingApproval(
          context: context,
          username: username,
          onEnterTrial: _enterTrialMode,
        );
      } else if (result.status == 'declined') {
        AuthStatusDialogs.showDeclined(context);
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    final fullName = _regFullNameCtrl.text.trim();
    final username = _regUsernameCtrl.text.trim().toLowerCase();
    final password = _regPasswordCtrl.text.trim();

    if (fullName.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Harap lengkapi semua kolom pendaftaran.';
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _errorMessage = 'Username minimal 3 karakter.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password minimal 6 karakter.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.register(
      username: username,
      password: password,
      fullName: fullName,
      avatarUrl: _selectedAvatar,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _loginUsernameCtrl.text = username;
      _loginPasswordCtrl.text = password;
      AuthStatusDialogs.showRegistrationSuccess(
        context: context,
        username: username,
        fullName: fullName,
        onContinue: () {
          setState(() => _isSignUpMode = false);
          _handleLogin();
        },
      );
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }

  void _enterTrialMode() async {
    await TrialService.setTrialMode(true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memulai Mode Trial (10 Resep & 10x Seduh)'),
        backgroundColor: Colors.orange,
      ),
    );
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                AuthHeader(isSignUpMode: _isSignUpMode),
                const SizedBox(height: 32),

                // Error message banner if any
                if (_errorMessage != null)
                  AuthErrorBanner(
                    errorMessage: _errorMessage!,
                    isSignUpMode: _isSignUpMode,
                    onSwitchToLogin: () {
                      setState(() {
                        _isSignUpMode = false;
                        _loginUsernameCtrl.text = _regUsernameCtrl.text.trim();
                        _errorMessage = null;
                      });
                    },
                  ),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _isSignUpMode
                      ? AuthSignUpForm(
                          fullNameController: _regFullNameCtrl,
                          usernameController: _regUsernameCtrl,
                          passwordController: _regPasswordCtrl,
                          selectedAvatar: _selectedAvatar,
                          isLoading: _isLoading,
                          onPickAvatar: _pickAvatar,
                          onRegister: _handleRegister,
                          onBackToLogin: () => setState(() => _isSignUpMode = false),
                        )
                      : AuthLoginForm(
                          usernameController: _loginUsernameCtrl,
                          passwordController: _loginPasswordCtrl,
                          isLoading: _isLoading,
                          isSuccess: _isSuccess,
                          onLogin: _handleLogin,
                          onSwitchToSignUp: () {
                            setState(() {
                              _isSignUpMode = true;
                              _errorMessage = null;
                            });
                          },
                        ),
                ),

                const SizedBox(height: 24),

                // Button Lanjutkan Trial
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _enterTrialMode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBrown,
                    side: const BorderSide(color: AppTheme.primaryBrown, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(CupertinoIcons.play_circle, size: 20),
                  label: const Text(
                    'Lanjutkan Trial',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mode Trial: Akses 10 Resep & 10x Brew Gratis',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
