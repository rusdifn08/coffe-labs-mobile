import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/trial_service.dart';
import '../services/profile_service.dart';
import 'admin_approval_screen.dart';
import 'admin_feedback_screen.dart';
import 'admin_version_screen.dart';
import 'feedback_screen.dart';
import 'settings_screen.dart';
import 'onboarding_screen.dart';
import 'brew_journal_screen.dart';
import 'favorites_screen.dart';
import '../services/feedback_service.dart';
import '../services/app_update_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthUser? _currentUser;
  bool _isTrial = false;
  int _trialBrews = 0;
  bool _isBrewLocked = false;
  Duration? _remainingLock;
  String _displayName = 'Barista';
  String? _avatarPath;
  int _pendingApprovalCount = 0;
  int _pendingFeedbackCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    AuthService.changeNotifier.addListener(_loadProfileData);
    TrialService.changeNotifier.addListener(_loadProfileData);
    ProfileService.changeNotifier.addListener(_loadProfileData);
    FeedbackService.changeNotifier.addListener(_loadProfileData);
  }

  @override
  void dispose() {
    AuthService.changeNotifier.removeListener(_loadProfileData);
    TrialService.changeNotifier.removeListener(_loadProfileData);
    ProfileService.changeNotifier.removeListener(_loadProfileData);
    FeedbackService.changeNotifier.removeListener(_loadProfileData);
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final user = await AuthService.getCurrentUser();
    final isTrial = await TrialService.isTrialMode();
    final trialBrews = await TrialService.getTrialBrewsCount();
    final isLocked = await TrialService.isBrewLocked();
    final remaining = await TrialService.getRemainingLockDuration();
    final name = await ProfileService.getUserName();
    final avatar = await ProfileService.getUserImagePath();

    int pendingCount = 0;
    int pendingFbCount = 0;
    if (user != null && user.isAdmin) {
      try {
        final users = await AuthService.getAdminUsers();
        pendingCount = users.where((u) => u.status == 'pending').length;
      } catch (_) {}

      try {
        final fbStats = await FeedbackService.getFeedbackStats();
        if (fbStats != null) {
          pendingFbCount = fbStats.pending;
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _currentUser = user;
      _isTrial = isTrial || user == null;
      _trialBrews = trialBrews;
      _isBrewLocked = isLocked;
      _remainingLock = remaining;
      _displayName = user?.fullName ?? name;
      _avatarPath = user?.avatarUrl.isNotEmpty == true ? user!.avatarUrl : avatar;
      _pendingApprovalCount = pendingCount;
      _pendingFeedbackCount = pendingFbCount;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.square_arrow_left, color: Colors.redAccent, size: 24),
            SizedBox(width: 10),
            Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini dan kembali ke halaman login?',
          style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthService.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _currentUser?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.gear_alt_fill),
            tooltip: 'Pengaturan',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ).then((_) => _loadProfileData()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
          : RefreshIndicator(
              color: AppTheme.primaryBrown,
              onRefresh: _loadProfileData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header Card
                    _buildUserHeaderCard(isAdmin),
                    const SizedBox(height: 16),

                    // Admin Panel Card (Hanya jika admin rusdifn08)
                    if (isAdmin) ...[
                      _buildAdminHubCard(),
                      const SizedBox(height: 12),
                      _buildAdminFeedbackHubCard(),
                      const SizedBox(height: 12),
                      _buildAdminVersionHubCard(),
                      const SizedBox(height: 16),
                    ],

                    // Trial Status Card (Hanya jika sedang dalam mode trial)
                    if (_isTrial) ...[
                      _buildTrialStatusCard(),
                      const SizedBox(height: 16),
                    ],

                    // Menu Section
                    _buildMenuSection(),

                    const SizedBox(height: 24),

                    // Tombol Logout
                    ElevatedButton.icon(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(CupertinoIcons.square_arrow_left, size: 20),
                      label: Text(
                        _isTrial ? 'Keluar dari Mode Trial' : 'Logout / Keluar Akun',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserHeaderCard(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ).then((_) => _loadProfileData());
            },
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppTheme.bgCream,
                  backgroundImage: ProfileService.getImageProvider(_avatarPath),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(CupertinoIcons.pencil, color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _displayName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser != null ? '@${_currentUser!.username}' : '@tamu_trial',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 8),
                _buildRoleBadge(isAdmin),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(bool isAdmin) {
    if (isAdmin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.shade700),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.shield_lefthalf_fill, size: 14, color: Colors.amber.shade900),
            const SizedBox(width: 6),
            Text(
              'ADMINISTRATOR',
              style: TextStyle(color: Colors.amber.shade900, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (_isTrial) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade400),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.hourglass, size: 14, color: Colors.orange.shade800),
            const SizedBox(width: 6),
            Text(
              'GUEST TRIAL',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade600),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.checkmark_seal_fill, size: 14, color: Colors.green.shade700),
            const SizedBox(width: 6),
            Text(
              'VERIFIED BARISTA',
              style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAdminHubCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade800, AppTheme.primaryBrown],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminApprovalScreen()),
            ).then((_) => _loadProfileData());
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.person_badge_plus, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Persetujuan Pendaftaran',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _pendingApprovalCount > 0
                            ? '$_pendingApprovalCount pendaftar menunggu persetujuan Anda'
                            : 'Kelola persetujuan & daftar barista',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
                if (_pendingApprovalCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_pendingApprovalCount Baru',
                      style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(CupertinoIcons.chevron_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminFeedbackHubCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade800, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminFeedbackScreen()),
            ).then((_) => _loadProfileData());
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pusat Feedback User',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _pendingFeedbackCount > 0
                            ? '$_pendingFeedbackCount masukan/laporan belum ditinjau'
                            : 'Kelola laporan bug, ide fitur & saran seduh',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
                if (_pendingFeedbackCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_pendingFeedbackCount Baru',
                      style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(CupertinoIcons.chevron_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminVersionHubCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade900, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminVersionScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.bolt_badge_a_fill, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Version Gatekeeper & OTA',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kontrol Shorebird OTA Patch & Rilis Native',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade300.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.shade200.withValues(alpha: 0.6)),
                  ),
                  child: const Text(
                    'Axum Gate',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(CupertinoIcons.chevron_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrialStatusCard() {
    final remainingBrews = (10 - _trialBrews).clamp(0, 10);
    final daysRemaining = _remainingLock != null ? (_remainingLock!.inDays + 1) : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.info_circle_fill, color: Colors.orange, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Mode Pengunjung Trial',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.brown),
                ),
              ),
              Text(
                '$_trialBrews / 10 Seduhan',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_trialBrews / 10).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.amber.shade200,
              color: _isBrewLocked ? Colors.redAccent : AppTheme.primaryBrown,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isBrewLocked
                ? '⚠️ Batas 10 seduh tercapai. Fitur terkunci selama 1 minggu — $daysRemaining hari tersisa.'
                : 'Akses terbatas: 10 resep & sisa $remainingBrews kali seduh gratis.',
            style: TextStyle(
              fontSize: 12,
              color: _isBrewLocked ? Colors.red.shade800 : Colors.brown.shade700,
              fontWeight: _isBrewLocked ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                'Login / Buka Akses Penuh',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Material(
      color: AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Tombol Pengaturan
          _buildMenuTile(
            icon: CupertinoIcons.gear_alt_fill,
            iconColor: AppTheme.primaryBrown,
            title: 'Pengaturan',
            subtitle: 'Ubah nama barista, avatar, dan preferensi aplikasi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ).then((_) => _loadProfileData());
            },
          ),
          const Divider(height: 1, indent: 64, color: AppTheme.dividerColor),

          // Jurnal Seduh
          _buildMenuTile(
            icon: CupertinoIcons.book_fill,
            iconColor: Colors.deepOrange,
            title: 'Catatan Seduh',
            subtitle: 'Lihat riwayat seduhan dan rating kopi Anda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BrewJournalScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 64, color: AppTheme.dividerColor),

          // Resep Favorit
          _buildMenuTile(
            icon: CupertinoIcons.heart_fill,
            iconColor: Colors.pinkAccent,
            title: 'Resep Favorit Saya',
            subtitle: 'Daftar resep yang telah Anda tandai',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 64, color: AppTheme.dividerColor),

          // Beri Masukan & Feedback
          _buildMenuTile(
            icon: CupertinoIcons.chat_bubble_2_fill,
            iconColor: Colors.teal,
            title: 'Beri Masukan & Feedback',
            subtitle: 'Laporkan masalah atau usulkan fitur baru',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 64, color: AppTheme.dividerColor),

          // Periksa Pembaruan Sistem
          _buildMenuTile(
            icon: CupertinoIcons.arrow_clockwise_circle_fill,
            iconColor: Colors.purple,
            title: 'Periksa Pembaruan Sistem',
            subtitle: 'Cek rilis versi terbaru & Shorebird OTA Patch',
            onTap: () {
              AppUpdateService.checkForUpdate(context: context, isManual: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
      ),
      trailing: const Icon(CupertinoIcons.chevron_forward, color: AppTheme.textMuted, size: 18),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }
}
