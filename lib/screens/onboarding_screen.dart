import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/trial_service.dart';
import '../services/profile_service.dart';
import 'main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isSignUpMode = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
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
      _errorMessage = null;
    });

    final result = await AuthService.login(username: username, password: password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.user?.isAdmin == true
                ? '👑 Login berhasil sebagai Admin Rusdi!'
                : 'Selamat datang kembali, ${result.user?.fullName}!',
          ),
          backgroundColor: AppTheme.primaryBrown,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } else {
      if (result.status == 'pending') {
        _showPendingApprovalDialog(username);
      } else if (result.status == 'declined') {
        _showDeclinedDialog();
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
      _loginPasswordCtrl.clear();
      _showRegistrationSuccessDialog(username);
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  void _showPendingApprovalDialog(String username) {
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
              _enterTrialMode();
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

  void _showDeclinedDialog() {
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

  void _showRegistrationSuccessDialog(String username) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Pendaftaran Berhasil!', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Akun '$username' berhasil dibuat!\n\nSesuai sistem keamanan, akun baru harus di-accept terlebih dahulu oleh Admin (rusdifn08) sebelum dapat login.",
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.info_circle, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sambil menunggu persetujuan, Anda dapat langsung mencoba aplikasi lewat "Lanjutkan Trial".',
                      style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isSignUpMode = false);
            },
            child: const Text('Ke Halaman Login', style: TextStyle(color: AppTheme.primaryBrown, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _enterTrialMode();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Lanjutkan Trial', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBrown.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(CupertinoIcons.flame_fill, color: Colors.white, size: 42),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Coffee Labs',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _isSignUpMode
                      ? 'Daftar Akun Barista Baru'
                      : 'Specialty Coffee Brewing Hub',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Error message banner if any
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_isSignUpMode &&
                            (_errorMessage!.contains('terdaftar') ||
                                _errorMessage!.contains('Login') ||
                                _errorMessage!.contains('timeout') ||
                                _errorMessage!.contains('Timeout'))) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBrown,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isSignUpMode = false;
                                  _loginUsernameCtrl.text = _regUsernameCtrl.text.trim();
                                  _errorMessage = null;
                                });
                              },
                              icon: const Icon(CupertinoIcons.arrow_right_circle_fill, size: 14, color: Colors.white),
                              label: const Text(
                                'Beralih ke Login',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

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
                  child: _isSignUpMode ? _buildSignUpForm() : _buildLoginForm(),
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

  Widget _buildLoginForm() {
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
          controller: _loginUsernameCtrl,
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
          controller: _loginPasswordCtrl,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
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
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBrown,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
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
        if (_isLoading) ...[
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
            onTap: () {
              setState(() {
                _isSignUpMode = true;
                _errorMessage = null;
              });
            },
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

  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.arrow_left, color: AppTheme.primaryBrown),
              onPressed: () => setState(() => _isSignUpMode = false),
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
          'Daftar akun baru. Akun akan ditinjau oleh Admin.',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 18),

        // Avatar Preview & Picker
        Center(
          child: GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.bgCream,
                  backgroundImage: ProfileService.getImageProvider(_selectedAvatar),
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
            onPressed: _pickAvatar,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text('Pilih Karakter Avatar', style: TextStyle(fontSize: 12, color: AppTheme.primaryBrown, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),

        // Full Name Field
        TextField(
          controller: _regFullNameCtrl,
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
          controller: _regUsernameCtrl,
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
          controller: _regPasswordCtrl,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleRegister(),
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
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.shield_lefthalf_fill, color: Colors.orange, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Setiap akun yang mendaftar harus disetujui (Accept) oleh Admin sebelum dapat login penuh.',
                  style: TextStyle(fontSize: 11, color: Colors.brown, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Tombol Sign Up
        ElevatedButton(
          onPressed: _isLoading ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBrown,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
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
        if (_isLoading) ...[
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
            onTap: () => setState(() => _isSignUpMode = false),
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
