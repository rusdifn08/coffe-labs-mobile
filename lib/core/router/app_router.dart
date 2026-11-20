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
import '../../features/monitoring/data/telemetry_batch_outbox_service.dart';
import '../../features/monitoring/presentation/route_lifecycle_observer.dart';
import '../../features/monitoring/presentation/screens/platform_monitoring_dashboard_screen.dart';
import '../../features/admin_control/controllers/system_control_sync_controller.dart';
import '../../features/admin_control/presentation/screens/admin_control_panel_screen.dart';
import '../../features/live_brew/presentation/screens/customer_live_brew_tracker_screen.dart';
import '../../features/qris_billing/presentation/screens/merchant_qris_bridge_admin_screen.dart';
import '../../features/qris_billing/presentation/screens/subscription_plan_selector_screen.dart';
import '../../features/multi_method_brewing/presentation/screens/cold_brew_and_drip_studio_screen.dart';
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
  static const String coldBrewAlarm = '/brew/cold-brew-alarm/:alarmId';
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
  static const String adminMonitoring = '/admin/monitoring';
  static const String adminQrisBridge = '/admin/qris-bridge';
  static const String adminControl = '/admin/control';
  static const String billingPlans = '/billing/plans';
  static const String aodShowcase = '/business/aod-showcase';
  static const String inAppTrainer = '/in-app-trainer';
  static const String liveBrew = '/livebrew';
  static const String liveBrewTracker = '/livebrew/:addressCode';
  static const String liveBrewBrandedSeat = '/livebrew/:cafeSlug/:seatSlug';
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

/// Evaluasi async redirect hanya saat cache cold-start belum terisi.
Future<String?> _evaluateRedirectAsync(
  Ref ref,
  GoRouterState state,
  AuthUser? authUser,
) async {
  final path = state.matchedLocation;

  final kioskBoot = await KioskEngineService.getKioskBootState();
  if ((kioskBoot.bootIntoAodKiosk || kioskBoot.isLocked) &&
      path != AppRoutes.aodShowcase) {
    return AppRoutes.aodShowcase;
  }

  if (path == AppRoutes.splash || path.startsWith('/livebrew')) {
    return null;
  }

  final isAuthed = authUser != null || await AuthService.isLoggedIn();
  final isTrial = await TrialService.isTrialMode();
  final isEnteringOnboarding = path == AppRoutes.onboarding;
  final allowUpgradeLogin = state.uri.queryParameters['upgrade'] == 'true';

  if (!isAuthed && !isTrial) {
    return isEnteringOnboarding ? null : AppRoutes.onboarding;
  }

  if (isAuthed && isEnteringOnboarding && !allowUpgradeLogin) {
    return AppRoutes.home;
  }

  if (path.startsWith('/admin')) {
    final isAdmin =
        (authUser?.isAdmin ?? false) || await AuthService.isAdmin();
    if (!isAdmin) {
      return AppRoutes.home;
    }
  }

  final lockedFeature =
      ref.read(systemControlProvider).snapshot.findLockedFeatureForRoute(path);
  if (lockedFeature != null) {
    final isAdmin =
        (authUser?.isAdmin ?? false) || await AuthService.isAdmin();
    if (!(isAdmin && lockedFeature.allowAdminBypass)) {
      return AppRoutes.home;
    }
  }

  return null;
}

/// Provider GoRouter terpusat yang diinjeksi dengan Riverpod Authentication & Role Guard.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = RouterAuthRefreshNotifier();

  // Dengarkan perubahan state AuthController & Control Plane Riverpod secara reaktif
  ref.listen(authControllerProvider, (_, _) {
    refreshNotifier.triggerRefresh();
  });
  ref.listen(systemControlProvider, (_, _) {
    refreshNotifier.triggerRefresh();
  });

  ref.onDispose(refreshNotifier.dispose);

  final lifecycleObserver = CoffeeLabsRouteAndLifecycleObserver(
    TelemetryBatchOutboxService.instance,
  );
  ref.onDispose(() {
    lifecycleObserver.detachLifecycle();
    TelemetryBatchOutboxService.instance.dispose();
  });

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    observers: [lifecycleObserver],
    redirect: (BuildContext context, GoRouterState state) {
      final path = state.matchedLocation;

      // Kiosk Route Guard: Jangan cegat bila sedang dalam AOD Showcase
      if (path == AppRoutes.aodShowcase) {
        return null;
      }

      // Synchronous fast-path: hindari Future/SharedPreferences/MethodChannel di setiap push navigasi
      final cachedKiosk = KioskEngineService.cachedBootState;
      final cachedLoggedIn = AuthService.cachedIsLoggedIn;
      final cachedTrial = TrialService.cachedIsTrialMode;
      final cachedAdmin = AuthService.cachedIsAdmin;
      final authUser = ref.read(authControllerProvider).value;

      if (cachedKiosk != null &&
          cachedLoggedIn != null &&
          cachedTrial != null) {
        if (cachedKiosk.bootIntoAodKiosk || cachedKiosk.isLocked) {
          return AppRoutes.aodShowcase;
        }
        if (path == AppRoutes.splash || path.startsWith('/livebrew')) {
          return null;
        }
        final isAuthed = authUser != null || cachedLoggedIn;
        final isEnteringOnboarding = path == AppRoutes.onboarding;
        final allowUpgradeLogin = state.uri.queryParameters['upgrade'] == 'true';

        if (!isAuthed && !cachedTrial) {
          return isEnteringOnboarding ? null : AppRoutes.onboarding;
        }
        if (isAuthed && isEnteringOnboarding && !allowUpgradeLogin) {
          return AppRoutes.home;
        }
        if (path.startsWith('/admin')) {
          final isAdmin = (authUser?.isAdmin ?? false) || (cachedAdmin ?? false);
          if (!isAdmin) {
            return AppRoutes.home;
          }
        }
        final lockedFeature = ref
            .read(systemControlProvider)
            .snapshot
            .findLockedFeatureForRoute(path);
        if (lockedFeature != null) {
          final isAdmin = (authUser?.isAdmin ?? false) || (cachedAdmin ?? false);
          if (!(isAdmin && lockedFeature.allowAdminBypass)) {
            return AppRoutes.home;
          }
        }
        return null;
      }

      return _evaluateRedirectAsync(ref, state, authUser);
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          transitionsBuilder: (context, anim, secondaryAnim, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionDuration: const Duration(milliseconds: 340),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          transitionsBuilder: (context, anim, secondaryAnim, child) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.02),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MainLayout(),
          transitionDuration: const Duration(milliseconds: 360),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          transitionsBuilder: (context, anim, secondaryAnim, child) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.018),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
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
        path: AppRoutes.coldBrewAlarm,
        builder: (context, state) => ColdBrewAndDripStudioScreen(
          recipe: state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : const {
                  'title': 'Cold Brew Concentrate',
                  'method': 'Cold Brew',
                  'category': 'Cold Brew',
                  'coffeeWeightGrams': 50,
                  'totalWaterWeightGrams': 500,
                  'waterTempCelsius': 4,
                  'totalTimeSeconds': 57600,
                  'steps': [],
                },
        ),
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
        builder: (context, state) => const SocialExploreAndFeedScreen(initialTabIndex: 2),
      ),
      GoRoute(
        path: AppRoutes.socialClubs,
        builder: (context, state) => const SocialExploreAndFeedScreen(initialTabIndex: 0),
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
        path: AppRoutes.adminMonitoring,
        builder: (context, state) => const PlatformMonitoringDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminQrisBridge,
        builder: (context, state) => const MerchantQrisBridgeAdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminControl,
        builder: (context, state) => const AdminControlPanelScreen(),
      ),
      GoRoute(
        path: AppRoutes.billingPlans,
        builder: (context, state) {
          final tier = state.uri.queryParameters['tier'] ?? 'pro';
          return SubscriptionPlanSelectorScreen(initialTier: tier);
        },
      ),
      GoRoute(
        path: AppRoutes.inAppTrainer,
        builder: (context, state) => const StudioAiHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.liveBrew,
        builder: (context, state) => const CustomerLiveBrewTrackerScreen(),
      ),
      GoRoute(
        path: AppRoutes.liveBrewTracker,
        builder: (context, state) {
          final code = state.pathParameters['addressCode'] ?? '';
          return CustomerLiveBrewTrackerScreen(addressCode: code);
        },
      ),
      GoRoute(
        path: AppRoutes.liveBrewBrandedSeat,
        builder: (context, state) {
          final cafeSlug = state.pathParameters['cafeSlug'] ?? '';
          final seatSlug = state.pathParameters['seatSlug'] ?? '';
          return CustomerLiveBrewTrackerScreen(
            cafeSlug: cafeSlug,
            seatSlug: seatSlug,
          );
        },
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
