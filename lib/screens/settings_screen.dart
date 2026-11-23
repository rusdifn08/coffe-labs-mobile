import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/moderation/content_moderation_guard.dart';
import '../core/moderation/moderation_alert_banner.dart';
import '../features/auth/utils/auth_navigation_helper.dart';
import '../features/settings/widgets/change_password_dialog.dart';
import '../features/settings/widgets/language_selector_dialog.dart';
import '../services/app_update_service.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../services/profile_service.dart';
import '../services/trial_service.dart';
import '../services/user_cloud_sync_service.dart';
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
  final TextEditingController _emailController = TextEditingController();
  String? _imagePath;
  String _selectedLanguage = 'en'; // Default English
  AuthUser? _currentUser;
  bool _isSyncingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    ProfileService.changeNotifier.addListener(_loadProfile);
    AuthService.changeNotifier.addListener(_loadProfile);
    TrialService.changeNotifier.addListener(_loadProfile);
    LanguageService.changeNotifier.addListener(_loadLanguage);
  }

  @override
  void dispose() {
    ProfileService.changeNotifier.removeListener(_loadProfile);
    AuthService.changeNotifier.removeListener(_loadProfile);
    TrialService.changeNotifier.removeListener(_loadProfile);
    LanguageService.changeNotifier.removeListener(_loadLanguage);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadLanguage() async {
    final lang = await LanguageService.getLanguage();
    if (mounted) setState(() => _selectedLanguage = lang);
  }

  void _loadProfile() async {
    await TrialService.getPolicy();
    final name = await ProfileService.getUserName();
    final img = await ProfileService.getUserImagePath();
    final lang = await LanguageService.getLanguage();
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _nameController.text = user?.fullName ?? name;
      _emailController.text = user?.email ?? '';
      _imagePath = (user?.avatarUrl.isNotEmpty == true) ? user!.avatarUrl : img;
      _selectedLanguage = lang;
      _currentUser = user;
    });
  }

  Future<void> _pickImage() async {
    await ProfileService.showAvatarPickerDialog(
      context: context,
      currentPath: _imagePath,
      onSelected: (newPath) async {
        if (!mounted) return;
        setState(() {
          _imagePath = newPath;
          _isSyncingProfile = true;
        });
        final result = await UserCloudSyncService.updateProfileAndSync(
          avatarPathOrUrl: newPath,
        );
        if (!mounted) return;
        setState(() {
          if (result.avatarUrl != null && result.avatarUrl!.isNotEmpty) {
            _imagePath = result.avatarUrl;
          }
          _isSyncingProfile = false;
        });
        final isEn = LanguageService.isEnglish;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.syncedToCloud
                  ? (isEn
                      ? 'Profile photo synced to cloud & Social Chat!'
                      : 'Foto profil berhasil disinkronkan ke cloud & Social Chat!')
                  : result.message,
            ),
            backgroundColor: result.syncedToCloud
                ? const Color(0xFF15803D)
                : AppTheme.primaryBrown,
          ),
        );
      },
    );
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final isEn = LanguageService.isEnglish;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEn ? 'Name cannot be empty' : 'Nama tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (email.isNotEmpty && !AuthService.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn
                ? 'Invalid email format. Example: name@gmail.com'
                : 'Format alamat email tidak valid. Contoh: nama@gmail.com',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final verdict = ContentModerationGuard.inspect(
      name,
      fieldLabel: 'Nama profil',
    );
    if (!verdict.isAllowed) {
      if (mounted) ModerationAlertFeedback.showBlockedSnackBar(context, verdict);
      return;
    }

    setState(() => _isSyncingProfile = true);
    final result = await UserCloudSyncService.updateProfileAndSync(
      fullName: name,
      email: email.isNotEmpty ? email : null,
    );
    if (!mounted) return;
    setState(() => _isSyncingProfile = false);

    final emailConflict = !result.syncedToCloud &&
        result.message.toLowerCase().contains('email');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.syncedToCloud
              ? (isEn
                  ? 'Profile & email saved and synced to cloud!'
                  : 'Profil & email berhasil disimpan dan disinkronkan ke cloud!')
              : result.message,
        ),
        backgroundColor: result.syncedToCloud
            ? const Color(0xFF15803D)
            : (emailConflict ? Colors.redAccent : AppTheme.primaryBrown),
      ),
    );
    if (result.syncedToCloud && Navigator.canPop(context)) {
      Navigator.pop(context, true);
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
                    onTap: _isSyncingProfile ? null : _pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: AppTheme.surfaceWhite,
                          backgroundImage: ProfileService.getImageProvider(_imagePath),
                        ),
                        if (_isSyncingProfile)
                          Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
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
            const SizedBox(height: 18),
            _buildAccountSessionCard(isEn),
            const SizedBox(height: 16),

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
                  if (_currentUser != null) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: isEn ? "Active Email" : "Email Aktif",
                        hintText: "nama@gmail.com",
                        labelStyle: const TextStyle(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.bgCream.withValues(alpha: 0.5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        prefixIcon: const Icon(CupertinoIcons.mail_solid, color: AppTheme.primaryBrown, size: 20),
                      ),
                    ),
                    if (_currentUser!.email == null || _currentUser!.email!.trim().isEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.info_circle_fill, size: 15, color: Colors.amber.shade800),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isEn
                                    ? 'Add your email to enable password reset & Coffee Labs updates.'
                                    : 'Tambahkan email aktif agar bisa reset lupa password & terima info Coffee Labs.',
                                style: TextStyle(fontSize: 11.5, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSyncingProfile ? null : _saveName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isEn ? "Save Profile" : "Simpan Profil",
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
              child: Material(
                color: Colors.transparent,
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
              child: Material(
                color: Colors.transparent,
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
              child: Material(
                color: Colors.transparent,
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
              child: Material(
                color: Colors.transparent,
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
            ),
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/images/coffee_labs_logo.png',
                width: 112,
                height: 112,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'v2.4.0 • Powered by Rust Axum & Shorebird Engine',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSessionCard(bool isEn) {
    final user = _currentUser;
    final isFullTrial =
        TrialService.isFullNonBusinessTrialActiveSync(user: user);

    if (user != null) {
      final tierLabel = user.isAdmin
          ? 'SUPERADMIN'
          : (user.isBusiness
              ? 'BUSINESS CAFE'
              : (user.isPro
                  ? 'COFFEE LABS PRO'
                  : (isFullTrial
                      ? 'TRIAL 7H FULL (NON-BISNIS)'
                      : 'AKUN TERDAFTAR (TRIAL)')));

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFF15803D).withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: Color(0xFF15803D),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${user.fullName} (@${user.username})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEn ? 'Active Status: $tierLabel' : 'Status Sesi: $tierLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
                    ),
                  ),
                  if (user.email != null && user.email!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF15803D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isEn ? 'LOGGED IN' : 'AKTIF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.person_crop_circle,
              color: AppTheme.primaryBrown,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Visitor Mode (Not Logged In)' : 'Mode Pengunjung (Belum Login)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEn
                      ? 'Log in to sync your barista profile & unlock features'
                      : 'Masuk akun resmi untuk sinkronisasi profil & fitur barista',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => AuthNavigationHelper.openLoginScreen(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isEn ? 'Log In' : 'Masuk',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
