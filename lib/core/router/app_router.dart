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
import '../../features/annotation_studio/presentation/studio_ai_hub_screen.dart';
import '../../features/communities/presentation/screens/community_workspace_screen.dart';
import '../../features/communities/presentation/screens/invite_token_join_screen.dart';
import '../../features/explore_feed/presentation/screens/social_explore_and_feed_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../features/social_chat/presentation/screens/social_coffee_chat_list_screen.dart';
import '../../features/social_chat/presentation/screens/social_coffee_chat_room_screen.dart';
import '../../features/social_profile_feed/presentation/screens/barista_directory_screen.dart';
import '../../features/social_profile_feed/presentation/screens/social_user_profile_screen.dart';
import '../../features/social_profile_feed/presentation/screens/thread_detail_screen.dart';
import '../../features/social_graph/presentation/screens/social_connections_tab_screen.dart';
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
  static const String socialProfiles = '/social/profiles';
  static const String socialExplore = '/social/explore';
  static const String socialClubs = '/social/clubs';
  static const String socialClubWorkspace = '/social/clubs/:clubId';
  static const String socialClubInviteToken = '/c/:token';
  static const String socialUserProfile = '/social/profile/:target';
  static const String socialUserConnections =
      '/social/profile/:target/connections';
  static const String socialThreadDetail = '/social/thread/:threadId';
  static const String socialChat = '/social/chat';
  static const String socialChatRoom = '/social/chat/:conversationId';
  static const String notifications = '/notifications';
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
          transitionDuration: const Duration(milliseconds: 550),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, anim, secondaryAnim, child) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: const Cubic(0.16, 1.0, 0.3, 1.0),
            );
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: anim,
                  curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
                ),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.035),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
                  child: child,
                ),
              ),
            );
          },
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
        path: AppRoutes.socialProfiles,
        builder: (context, state) => const BaristaDirectoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.socialUserProfile,
        builder: (context, state) {
          final rawTarget = state.pathParameters['target'] ?? 'me';
          final target = Uri.decodeComponent(rawTarget);
          return SocialUserProfileScreen(targetUserOrUsername: target);
        },
      ),
      GoRoute(
        path: AppRoutes.socialUserConnections,
        builder: (context, state) {
          final target = Uri.decodeComponent(
            state.pathParameters['target'] ?? 'me',
          );
          final tab = state.uri.queryParameters['tab'] ?? 'followers';
          final initialTabIndex =
              tab == 'mutual' ? 0 : (tab == 'following' ? 2 : 1);
          final displayName = state.uri.queryParameters['name'] ?? '';
          final isOwn = state.uri.queryParameters['own'] == '1';
          return SocialConnectionsTabScreen(
            targetUserOrUsername: target,
            displayName: displayName,
            initialTabIndex: initialTabIndex,
            isOwnProfile: isOwn,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.socialThreadDetail,
        builder: (context, state) {
          final threadId = state.pathParameters['threadId'] ?? '';
          return ThreadDetailScreen(threadId: threadId);
        },
      ),
      GoRoute(
        path: AppRoutes.socialChat,
        builder: (context, state) => const SocialCoffeeChatListScreen(),
      ),
      GoRoute(
        path: AppRoutes.socialChatRoom,
        builder: (context, state) {
          final convId = state.pathParameters['conversationId'] ?? '';
          return SocialCoffeeChatRoomScreen(conversationId: convId);
        },
      ),
      GoRoute(
        path: '/social/chat/room/:conversationId',
        builder: (context, state) {
          final convId = state.pathParameters['conversationId'] ?? '';
          return SocialCoffeeChatRoomScreen(conversationId: convId);
        },
      ),
      GoRoute(
        path: '/social/threads/:threadId',
        builder: (context, state) {
          final threadId = state.pathParameters['threadId'] ?? '';
          return ThreadDetailScreen(threadId: threadId);
        },
      ),
      GoRoute(
        path: AppRoutes.socialExplore,
        builder: (context, state) => const SocialExploreAndFeedScreen(initialTabIndex: 0),
      ),
      GoRoute(
        path: AppRoutes.socialClubs,
        builder: (context, state) => const SocialExploreAndFeedScreen(initialTabIndex: 2),
      ),
      GoRoute(
        path: AppRoutes.socialClubWorkspace,
        builder: (context, state) {
          final clubId = state.pathParameters['clubId'] ?? '';
          return CommunityWorkspaceScreen(communityId: clubId);
        },
      ),
      GoRoute(
        path: AppRoutes.socialClubInviteToken,
        builder: (context, state) {
          final token = state.pathParameters['token'] ?? '';
          return InviteTokenJoinScreen(token: token);
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationCenterScreen(),
      ),
      GoRoute(
        path: '/settings/subscription',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/brew/timer',
        builder: (context, state) => BrewTimerScreen(recipeData: state.extra),
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
        builder: (context, state) => const StudioAiHubScreen(),
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
