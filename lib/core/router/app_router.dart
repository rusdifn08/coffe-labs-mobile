import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../screens/add_recipe_screen.dart';
import '../../screens/admin_approval_screen.dart';
import '../../screens/admin_feedback_screen.dart';
import '../../screens/admin_version_screen.dart';
import '../../screens/barista_profile_screen.dart';
import '../../screens/bean_radar_screen.dart';
import '../../screens/brew_timer_screen.dart';
import '../../screens/dial_in_assistant_screen.dart';
import '../../screens/favorites_screen.dart';
import '../../screens/main_layout.dart';
import '../../screens/marketplace_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/recipe_detail_screen.dart';
import '../../screens/recipe_feed_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/smart_scale_screen.dart';
import '../../screens/social_coffee_screen.dart';
import '../../screens/splash_screen.dart';
import '../../services/auth_service.dart';
import '../../services/trial_service.dart';
import '../../features/business_pos/screens/aod_kiosk_showcase_route_wrapper.dart';
import '../../features/in_app_trainer/presentation/in_app_bean_trainer_screen.dart';
import '../../models/business_pos_models.dart';
import '../services/kiosk_engine_service.dart';

part 'app_router.g.dart';

/// Konstanta jalur rute deklaratif aplikasi Coffee Labs.
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String recipes = '/recipes';
  static const String recipeDetail = '/recipe-detail';
  static const String addRecipe = '/add-recipe';
  static const String brewTimer = '/brew-timer';
  static const String baristaProfile = '/barista';
  static const String favorites = '/favorites';
  static const String settings = '/settings';
  static const String social = '/social';
  static const String smartScale = '/smart-scale';
  static const String marketplace = '/marketplace';
  static const String beanRadar = '/bean-radar';
  static const String dialIn = '/dial-in';
  static const String adminApproval = '/admin/approval';
  static const String adminFeedback = '/admin/feedback';
  static const String adminVersion = '/admin/version';
  static const String aodShowcase = '/business/aod-showcase';
  static const String inAppTrainer = '/in-app-trainer';
}

/// Listenable bridge yang memicu evaluasi ulang Route Guard pada GoRouter
/// setiap kali state otentikasi Riverpod, AuthService, atau TrialService berubah.
class RouterAuthRefreshNotifier extends ChangeNotifier {
  RouterAuthRefreshNotifier() {
    AuthService.changeNotifier.addListener(notifyListeners);
    TrialService.changeNotifier.addListener(notifyListeners);
  }

  void triggerRefresh() => notifyListeners();

  @override
  void dispose() {
    AuthService.changeNotifier.removeListener(notifyListeners);
    TrialService.changeNotifier.removeListener(notifyListeners);
    super.dispose();
  }
}

/// Provider GoRouter terpusat yang diinjeksi dengan Riverpod Authentication & Role Guard.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = RouterAuthRefreshNotifier();

  // Dengarkan perubahan state AuthController Riverpod secara reaktif
  ref.listen(authControllerProvider, (_, _) {
    refreshNotifier.triggerRefresh();
  });

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) async {
      final path = state.matchedLocation;

      // Kiosk Route Guard: Jangan cegat bila sedang dalam AOD Showcase
      if (path == AppRoutes.aodShowcase) {
        return null;
      }

      // Kiosk Direct Cold-Boot Check: Jika tablet baru reboot saat Kiosk Mode aktif
      final kioskBoot = await KioskEngineService.getKioskBootState();
      if ((kioskBoot.bootIntoAodKiosk || kioskBoot.isLocked) && path != AppRoutes.aodShowcase) {
        return AppRoutes.aodShowcase;
      }

      // Biarkan halaman Splash menjalankan animasi pembuka & pengecekan sesi awal
      if (path == AppRoutes.splash) {
        return null;
      }

      final authUser = ref.read(authControllerProvider).value;
      final isAuthed = authUser != null || await AuthService.isLoggedIn();
      final isTrial = await TrialService.isTrialMode();
      final isEnteringOnboarding = path == AppRoutes.onboarding;
      final allowUpgradeLogin = state.uri.queryParameters['upgrade'] == 'true';

      // Guard 1: Pengguna belum login dan belum mengaktifkan mode trial -> arahkan ke Onboarding
      if (!isAuthed && !isTrial) {
        return isEnteringOnboarding ? null : AppRoutes.onboarding;
      }

      // Guard 2: Pengguna sudah terotentikasi penuh dan berada di halaman Onboarding -> arahkan ke Home
      if (isAuthed && isEnteringOnboarding && !allowUpgradeLogin) {
        return AppRoutes.home;
      }

      // Guard 3: Proteksi Rute Khusus Admin (/admin/*)
      if (path.startsWith('/admin')) {
        final isAdmin = (authUser?.isAdmin ?? false) || await AuthService.isAdmin();
        if (!isAdmin) {
          return AppRoutes.home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, anim, secondaryAnim, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, anim, secondaryAnim, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MainLayout(),
          transitionsBuilder: (context, anim, secondaryAnim, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.recipes,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RecipeFeedScreen(
            initialMethodFilter: extra?['methodFilter'] as String?,
            initialMethodTitle: extra?['methodTitle'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.recipeDetail,
        builder: (context, state) => RecipeDetailScreen(recipeData: state.extra),
      ),
      GoRoute(
        path: AppRoutes.addRecipe,
        builder: (context, state) => const AddRecipeScreen(),
      ),
      GoRoute(
        path: AppRoutes.brewTimer,
        builder: (context, state) => BrewTimerScreen(recipeData: state.extra),
      ),
      GoRoute(
        path: AppRoutes.baristaProfile,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? const {};
          return BaristaProfileScreen(
            rawAuthor: args['rawAuthor']?.toString() ?? '',
            imageUrl: args['imageUrl'] as String?,
            coverImageUrl: args['coverImageUrl'] as String?,
            heroTag: args['heroTag'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.social,
        builder: (context, state) => const SocialCoffeeScreen(),
      ),
      GoRoute(
        path: AppRoutes.smartScale,
        builder: (context, state) => const SmartScaleScreen(),
      ),
      GoRoute(
        path: AppRoutes.marketplace,
        builder: (context, state) => const MarketplaceScreen(),
      ),
      GoRoute(
        path: AppRoutes.beanRadar,
        builder: (context, state) => const BeanRadarScreen(),
      ),
      GoRoute(
        path: AppRoutes.dialIn,
        builder: (context, state) => const DialInAssistantScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminApproval,
        builder: (context, state) => const AdminApprovalScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminFeedback,
        builder: (context, state) => const AdminFeedbackScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminVersion,
        builder: (context, state) => const AdminVersionScreen(),
      ),
      GoRoute(
        path: AppRoutes.inAppTrainer,
        builder: (context, state) => const InAppBeanTrainerScreen(),
      ),
      GoRoute(
        path: AppRoutes.aodShowcase,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AodKioskShowcaseRouteWrapper(
              passedConfig: extra?['config'] as BusinessStoreConfig?,
              passedMenuItems: extra?['menuItems'] as List<BusinessMenuItem>?,
            ),
            transitionsBuilder: (context, anim, secondaryAnim, child) =>
                FadeTransition(opacity: anim, child: child),
          );
        },
      ),
    ],
  );
}
