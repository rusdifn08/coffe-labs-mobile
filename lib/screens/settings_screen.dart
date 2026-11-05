import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../features/settings/widgets/change_password_dialog.dart';
import '../features/settings/widgets/language_selector_dialog.dart';
import '../services/app_update_service.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/receipt_customization_sheet.dart';
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
        final isEn = LanguageService.isEnglish;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEn ? 'Profile name successfully saved!' : 'Nama profil berhasil disimpan!'),
            backgroundColor: AppTheme.primaryBrown,
          ),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      }
    } else {
      final isEn = LanguageService.isEnglish;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEn ? 'Name cannot be empty' : 'Nama tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(isEn ? 'Profile Settings' : 'Pengaturan Profil'),
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
                  ),
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
                label: Text(
                  isEn ? "Change Avatar Character" : "Ganti Karakter Avatar",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
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
                  Text(
                    isEn ? 'Barista Identity' : 'Identitas Barista',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: isEn ? "Full Name" : "Nama Lengkap",
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
                      child: Text(
                        isEn ? "Save Name" : "Simpan Nama",
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
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
                  Text(
                    isEn ? 'Security & Password' : 'Keamanan & Kata Sandi',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                  ),
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
                    title: Text(
                      isEn ? 'Change Account Password' : 'Ubah Password Akun',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      _currentUser != null
                          ? (isEn ? 'Update password for @${_currentUser!.username}' : 'Perbarui kata sandi akun @${_currentUser!.username}')
                          : (isEn ? 'Please log in to your account first' : 'Login akun terlebih dahulu'),
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                    trailing: const Icon(CupertinoIcons.chevron_forward, size: 18, color: AppTheme.textMuted),
                    onTap: () => ChangePasswordDialog.show(context, _currentUser),
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
                  Text(
                    isEn ? 'Language & Region' : 'Bahasa & Wilayah',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                  ),
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
                    title: Text(isEn ? 'Language' : 'Bahasa / Language', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(
                      LanguageService.getLanguageLabel(_selectedLanguage),
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.primaryBrown, fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(CupertinoIcons.chevron_forward, size: 18, color: AppTheme.textMuted),
                    onTap: () => LanguageSelectorDialog.show(
                      context,
                      selectedLanguage: _selectedLanguage,
                      onLanguageSelected: (lang) => setState(() => _selectedLanguage = lang),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // KUSTOMISASI STRUK KASIR & TOKO
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
                  Text(
                    isEn ? 'Receipt & Store Branding' : 'Kustomisasi Struk Kasir & Toko',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.printer_fill, color: Colors.deepOrange, size: 22),
                    ),
                    title: Text(
                      isEn ? 'Customize Receipt Header' : 'Header Struk Kasir',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      isEn
                          ? 'Set store name, slogan, icon, barista & social handle'
                          : 'Ubah nama kedai, slogan, ikon, barista & catatan kaki',
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
                    trailing: const Icon(CupertinoIcons.chevron_forward, size: 18, color: AppTheme.textMuted),
                    onTap: () => ReceiptCustomizationSheet.show(context),
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
                  Text(
                    isEn ? 'Support & System' : 'Dukungan & Sistem',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                  ),
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
                    title: Text(
                      isEn ? 'Feedback / Report Bug' : 'Beri Masukan / Laporkan Bug',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      isEn ? 'Send feedback directly to development team' : 'Kirim masukan langsung ke tim pengembang',
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
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
                    title: Text(
                      isEn ? 'Check System Updates' : 'Periksa Pembaruan Sistem',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      isEn ? 'OTA Shorebird Patch & Native Version' : 'OTA Shorebird Patch & Versi Native',
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                    ),
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
