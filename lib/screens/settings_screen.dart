import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/app_update_service.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import 'feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _imagePath;
  String _selectedLanguage = 'en'; // Default English
  AuthUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    ProfileService.changeNotifier.addListener(_loadProfile);
    LanguageService.changeNotifier.addListener(_loadLanguage);
  }

  @override
  void dispose() {
    ProfileService.changeNotifier.removeListener(_loadProfile);
    LanguageService.changeNotifier.removeListener(_loadLanguage);
    _nameController.dispose();
    super.dispose();
  }

  void _loadLanguage() async {
    final lang = await LanguageService.getLanguage();
    if (mounted) setState(() => _selectedLanguage = lang);
  }

  void _loadProfile() async {
    final name = await ProfileService.getUserName();
    final img = await ProfileService.getUserImagePath();
    final lang = await LanguageService.getLanguage();
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _nameController.text = name;
      _imagePath = img;
      _selectedLanguage = lang;
      _currentUser = user;
    });
  }

  Future<void> _pickImage() async {
    await ProfileService.showAvatarPickerDialog(
      context: context,
      currentPath: _imagePath,
      onSelected: (newPath) async {
        setState(() {
          _imagePath = newPath;
        });
        await ProfileService.setUserImagePath(newPath);
      },
    );
  }

  void _saveName() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await ProfileService.setUserName(name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nama profil berhasil disimpan!'),
            backgroundColor: AppTheme.primaryBrown,
          ),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitur ubah password memerlukan akun login aktif.'),
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
          title: const Row(
            children: [
              Icon(CupertinoIcons.lock_shield_fill, color: AppTheme.primaryBrown, size: 24),
              SizedBox(width: 10),
              Text('Ubah Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Masukkan kata sandi lama dan kata sandi baru minimal 6 karakter.',
                  style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),

                // Password Saat Ini
                TextField(
                  controller: currentPassCtrl,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Password Saat Ini',
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
                    labelText: 'Password Baru (min. 6)',
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
                    labelText: 'Konfirmasi Password Baru',
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
              child: const Text('Batal', style: TextStyle(color: AppTheme.textMuted)),
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
                          const SnackBar(content: Text('Masukkan password saat ini.'), backgroundColor: Colors.redAccent),
                        );
                        return;
                      }
                      if (newPass.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password baru minimal 6 karakter.'), backgroundColor: Colors.redAccent),
                        );
                        return;
                      }
                      if (newPass != confirmPass) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Konfirmasi password tidak cocok!'), backgroundColor: Colors.redAccent),
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

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Status update password.'),
                            backgroundColor: result['success'] == true ? Colors.green : Colors.redAccent,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan Password Baru'),
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.globe, color: AppTheme.primaryBrown, size: 24),
            SizedBox(width: 10),
            Text('Pilih Bahasa / Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                await LanguageService.setLanguage('en');
                setState(() => _selectedLanguage = 'en');
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language set to English (Default).'), backgroundColor: AppTheme.primaryBrown),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedLanguage == 'en' ? AppTheme.primaryBrown.withValues(alpha: 0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedLanguage == 'en' ? AppTheme.primaryBrown : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('English', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(width: 6),
                              Text('(Default)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text('Interface stays in English', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    if (_selectedLanguage == 'en')
                      const Icon(CupertinoIcons.checkmark_circle_fill, color: AppTheme.primaryBrown, size: 20)
                    else
                      Icon(CupertinoIcons.circle, color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                await LanguageService.setLanguage('id');
                setState(() => _selectedLanguage = 'id');
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bahasa diubah ke Bahasa Indonesia.'), backgroundColor: AppTheme.primaryBrown),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedLanguage == 'id' ? AppTheme.primaryBrown.withValues(alpha: 0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedLanguage == 'id' ? AppTheme.primaryBrown : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🇮🇩', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bahasa Indonesia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('Antarmuka dalam Bahasa Indonesia', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    if (_selectedLanguage == 'id')
                      const Icon(CupertinoIcons.checkmark_circle_fill, color: AppTheme.primaryBrown, size: 20)
                    else
                      Icon(CupertinoIcons.circle, color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup', style: TextStyle(color: AppTheme.primaryBrown))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Pengaturan Profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AVATAR SECTION
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: AppTheme.surfaceWhite,
                      backgroundImage: ProfileService.getImageProvider(_imagePath),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.bgCream, width: 3),
                        ),
                        child: const Icon(CupertinoIcons.camera_fill, color: Colors.white, size: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBrown,
                  side: const BorderSide(color: AppTheme.primaryBrown),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(CupertinoIcons.sparkles, size: 14),
                label: const Text("Ganti Karakter Avatar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 24),

            // NAMA PROFILE SECTION
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Identitas Barista', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Nama Lengkap",
                      labelStyle: const TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      prefixIcon: const Icon(CupertinoIcons.person_fill, color: AppTheme.primaryBrown, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Simpan Nama", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // PENGATURAN KEAMANAN & PASSWORD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Keamanan & Kata Sandi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.lock_shield_fill, color: Colors.brown, size: 22),
                    ),
                    title: const Text('Ubah Password Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      _currentUser != null ? 'Perbarui kata sandi akun @${_currentUser!.username}' : 'Login akun terlebih dahulu',
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                    trailing: const Icon(CupertinoIcons.chevron_forward, size: 18, color: AppTheme.textMuted),
                    onTap: _showChangePasswordDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // PENGATURAN BAHASA (LANGUAGE)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bahasa & Wilayah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.globe, color: Colors.blueAccent, size: 22),
                    ),
                    title: const Text('Bahasa / Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      LanguageService.getLanguageLabel(_selectedLanguage),
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.primaryBrown, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(CupertinoIcons.chevron_forward, size: 18, color: AppTheme.textMuted),
                    onTap: _showLanguageDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DUKUNGAN & UPDATE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dukungan & Sistem', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.teal, size: 22),
                    ),
                    title: const Text('Beri Masukan / Laporkan Bug', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Kirim masukan langsung ke tim pengembang', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
                    trailing: const Icon(CupertinoIcons.chevron_forward, size: 18, color: AppTheme.textMuted),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.arrow_clockwise_circle_fill, color: Colors.purple, size: 22),
                    ),
                    title: const Text('Periksa Pembaruan Sistem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('OTA Shorebird Patch & Versi Native', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
                    trailing: const Icon(CupertinoIcons.chevron_forward, size: 18, color: AppTheme.textMuted),
                    onTap: () {
                      AppUpdateService.checkForUpdate(context: context, isManual: true);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Coffee Labs v1.0.0\nPowered by Rust Axum & Shorebird Engine',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
