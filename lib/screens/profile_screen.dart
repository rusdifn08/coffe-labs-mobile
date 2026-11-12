import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/router/app_router.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/gamification/services/gamification_service.dart';
import '../features/profile/widgets/profile_admin_hub_cards.dart';
import '../features/profile/widgets/profile_menu_section.dart';
import '../features/profile/widgets/profile_subscription_card.dart';
import '../features/profile/widgets/profile_trial_card.dart';
import '../features/profile/widgets/user_profile_header_card.dart';
import '../features/business_pos/widgets/business_suite_launcher_card.dart';
import '../models/subscription_plan.dart';
import '../services/auth_service.dart';
import '../services/feedback_service.dart';
import '../services/profile_service.dart';
import '../services/subscription_service.dart';
import '../services/trial_service.dart';
import '../theme/app_theme.dart';

/// Halaman Profil Pengguna berbasis ConsumerStatefulWidget & navigasi GoRouter.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  AuthUser? _currentUser;
  bool _isTrial = false;
  String _displayName = 'Barista';
  String? _avatarPath;
  SubscriptionPlan _currentPlan = SubscriptionPlan.trial;
  int _totalUsersCount = 0;
  int _newRegistrationsCount = 0;
  int _pendingFeedbackCount = 0;
  GamificationStats? _gamificationStats;
  bool _isLoading = true;
  bool _isSyncing = false;
  DateTime? _lastAdminStatsFetch;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    AuthService.changeNotifier.addListener(_loadProfileData);
    TrialService.changeNotifier.addListener(_loadProfileData);
    ProfileService.changeNotifier.addListener(_loadProfileData);
    FeedbackService.changeNotifier.addListener(_loadProfileData);
    SubscriptionService.changeNotifier.addListener(_loadProfileData);
    GamificationService.changeNotifier.addListener(_loadProfileData);
  }

  @override
  void dispose() {
    AuthService.changeNotifier.removeListener(_loadProfileData);
    TrialService.changeNotifier.removeListener(_loadProfileData);
    ProfileService.changeNotifier.removeListener(_loadProfileData);
    FeedbackService.changeNotifier.removeListener(_loadProfileData);
    SubscriptionService.changeNotifier.removeListener(_loadProfileData);
    GamificationService.changeNotifier.removeListener(_loadProfileData);
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // 1. Sinkronisasi status profil terbaru dari backend server di background (jika online)
      AuthUser? user = await AuthService.getCurrentUser();
      if (user != null) {
        AuthService.syncProfile().then((synced) {
          if (synced != null && mounted && synced.tier != user.tier) {
            setState(() {
              _currentUser = synced;
            });
          }
        }).catchError((_) {});
      }

      final plan = await SubscriptionService.getCurrentPlan();
      final isTrial = await TrialService.isTrialMode();
      final name = await ProfileService.getUserName();
      final avatar = await ProfileService.getUserImagePath();
      final gStats = await GamificationService.instance.getStats();

      // Validasi RBAC tingkat tinggi: deteksi status Business atau Pro secara ketat
      // Jika ada akun login resmi, OTORITAS TERTINGGI adalah akun tersebut, BUKAN preferensi lokal!
      final bool isBusinessUser = user != null
          ? (user.isAdmin || user.isBusiness || user.username.toLowerCase() == 'bisnis123')
          : (plan.tier == SubscriptionTier.business);

      final bool isProUser = user != null
          ? (user.isPro || isBusinessUser)
          : (plan.tier == SubscriptionTier.pro || isBusinessUser);

      final effectivePlan = isBusinessUser
          ? SubscriptionPlan.business
          : (isProUser ? SubscriptionPlan.pro : SubscriptionPlan.trial);

      // Auto-repair & auto-heal persistensi lokal
      if (isBusinessUser || isProUser) {
        if (isTrial || plan.tier == SubscriptionTier.trial) {
          await TrialService.setTrialMode(false);
          await SubscriptionService.activatePlan(
            effectivePlan,
            paymentMethod: isBusinessUser ? 'Business Commercial License' : 'Pro Lifetime License',
          );
        }
      } else if (user != null) {
        // Auto-heal: Akun terdaftar biasa (trial) yang sebelumnya tercemar lisensi lokal direset tuntas!
        if (plan.tier != SubscriptionTier.trial) {
          await SubscriptionService.resetToTrial();
        }
        if (!isTrial) {
          await TrialService.setTrialMode(true);
        }
      }

      int totalUsers = _totalUsersCount;
      int newRegistrations = _newRegistrationsCount;
      int pendingFbCount = _pendingFeedbackCount;

      final now = DateTime.now();
      final shouldFetchStats = _lastAdminStatsFetch == null ||
          now.difference(_lastAdminStatsFetch!) > const Duration(seconds: 30);

      if (user != null && user.isAdmin && shouldFetchStats) {
        _lastAdminStatsFetch = now;
        try {
          final stats = await AuthService.getAdminUserStats();
          if (stats.totalUsers > 0) {
            totalUsers = stats.totalUsers;
            newRegistrations = stats.newRegistrations7d;
          } else {
            final users = await AuthService.getAdminUsers();
            totalUsers = users.length;
            newRegistrations = users.where((u) {
              if (u.status == 'pending') return true;
              if (u.createdAt == null) return false;
              try {
                return DateTime.now().difference(DateTime.parse(u.createdAt!)).inDays <= 7;
              } catch (_) {
                return false;
              }
            }).length;
          }
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
        _currentPlan = effectivePlan;
        // Pengguna adalah trial jika bukan admin, bukan business, dan bukan pro
        _isTrial = !isProUser && !isBusinessUser && (user == null || !user.isAdmin);
        _displayName = user?.fullName ?? name;
        _avatarPath = user?.avatarUrl.isNotEmpty == true ? user!.avatarUrl : avatar;
        _totalUsersCount = totalUsers;
        _newRegistrationsCount = newRegistrations;
        _pendingFeedbackCount = pendingFbCount;
        _gamificationStats = gStats;
        _isLoading = false;
      });
    } finally {
      _isSyncing = false;
    }
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
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;

    context.go(AppRoutes.onboarding);
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
            onPressed: () async {
              await context.push(AppRoutes.settings);
              _loadProfileData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrown))
          : RefreshIndicator(
              color: AppTheme.primaryBrown,
              onRefresh: _loadProfileData,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final mediaQuery = MediaQuery.of(context);
                  final isLandscape = mediaQuery.orientation == Orientation.landscape;
                  final isWide = constraints.maxWidth >= 720;

                  if (isLandscape || isWide) {
                    // Tampilan 2-Kolom Kompak & Profesional untuk Mode Landscape / Tablet
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kolom Kiri: Profil Pengguna, EXP Gamifikasi, Lisensi
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                UserProfileHeaderCard(
                                  currentUser: _currentUser,
                                  displayName: _displayName,
                                  avatarPath: _avatarPath,
                                  isTrial: _isTrial,
                                  isAdmin: isAdmin,
                                  currentTier: _currentPlan.tier,
                                  level: _gamificationStats?.level,
                                  gamificationStats: _gamificationStats,
                                  onTapAvatar: () async {
                                    await context.push(AppRoutes.settings);
                                    _loadProfileData();
                                  },
                                ),
                                const SizedBox(height: 12),
                                if (!isAdmin) ...[
                                  ProfileSubscriptionCard(
                                    currentPlan: _currentPlan,
                                    isTrial: _isTrial,
                                    onRefresh: _loadProfileData,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (_isTrial && _currentPlan.tier == SubscriptionTier.trial) ...[
                                  const ProfileTrialCard(),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Kolom Kanan: Panel Kontrol Admin, Daftar Menu, Logout
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (isAdmin) ...[
                                  ProfileAdminHubCards(
                                    totalUsersCount: _totalUsersCount,
                                    newRegistrationsCount: _newRegistrationsCount,
                                    pendingFeedbackCount: _pendingFeedbackCount,
                                    onRefresh: _loadProfileData,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                BusinessSuiteLauncherCard(
                                  isBusiness: isAdmin ||
                                      _currentPlan.tier == SubscriptionTier.business,
                                ),
                                const SizedBox(height: 12),
                                ProfileMenuSection(
                                  onOpenSettings: _loadProfileData,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _handleLogout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(CupertinoIcons.square_arrow_left, size: 18),
                                  label: Text(
                                    _isTrial ? 'Keluar dari Mode Trial' : 'Logout / Keluar Akun',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Mode Portrait Standar: 1-Kolom Ramping
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Header Card with Integrated Gamification
                        UserProfileHeaderCard(
                          currentUser: _currentUser,
                          displayName: _displayName,
                          avatarPath: _avatarPath,
                          isTrial: _isTrial,
                          isAdmin: isAdmin,
                          currentTier: _currentPlan.tier,
                          level: _gamificationStats?.level,
                          gamificationStats: _gamificationStats,
                          onTapAvatar: () async {
                            await context.push(AppRoutes.settings);
                            _loadProfileData();
                          },
                        ),
                        const SizedBox(height: 12),

                        // Admin Panel Cards (Hanya jika admin rusdifn08)
                        if (isAdmin) ...[
                          ProfileAdminHubCards(
                            totalUsersCount: _totalUsersCount,
                            newRegistrationsCount: _newRegistrationsCount,
                            pendingFeedbackCount: _pendingFeedbackCount,
                            onRefresh: _loadProfileData,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Kartu Pembelian Lisensi Coffe Labs Pro (99K) & Business (249K)
                        if (!isAdmin) ...[
                          ProfileSubscriptionCard(
                            currentPlan: _currentPlan,
                            isTrial: _isTrial,
                            onRefresh: _loadProfileData,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Status Card Mode Pengunjung (Akses Ekosistem Terbuka)
                        if (_isTrial && _currentPlan.tier == SubscriptionTier.trial) ...[
                          const ProfileTrialCard(),
                          const SizedBox(height: 12),
                        ],

                        // Mode Business (Eksklusif Business)
                        BusinessSuiteLauncherCard(
                          isBusiness: isAdmin ||
                              _currentPlan.tier == SubscriptionTier.business,
                        ),
                        const SizedBox(height: 12),

                        // Menu Section
                        ProfileMenuSection(
                          onOpenSettings: _loadProfileData,
                        ),

                        const SizedBox(height: 18),

                        // Tombol Logout
                        ElevatedButton.icon(
                          onPressed: _handleLogout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          icon: const Icon(CupertinoIcons.square_arrow_left, size: 18),
                          label: Text(
                            _isTrial ? 'Keluar dari Mode Trial' : 'Logout / Keluar Akun',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
