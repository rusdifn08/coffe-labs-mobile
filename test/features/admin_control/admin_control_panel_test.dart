import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:coffee_hub_mobile/features/admin_control/controllers/system_control_sync_controller.dart';
import 'package:coffee_hub_mobile/features/admin_control/data/admin_control_api_service.dart';
import 'package:coffee_hub_mobile/features/admin_control/models/admin_control_models.dart';
import 'package:coffee_hub_mobile/features/admin_control/presentation/screens/admin_control_panel_screen.dart';
import 'package:coffee_hub_mobile/features/admin_control/widgets/active_feature_lock_kickout_overlay.dart';
import 'package:coffee_hub_mobile/features/auth/controllers/auth_controller.dart';
import 'package:coffee_hub_mobile/features/qris_billing/presentation/screens/subscription_plan_selector_screen.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';
import 'package:coffee_hub_mobile/widgets/toolkit_card.dart';

class _FakeAuthController extends AuthController {
  final AuthUser? _user;
  _FakeAuthController(this._user);

  @override
  Future<AuthUser?> build() async => _user;
}

class _FakeAdminControlApiService extends AdminControlApiService {
  SystemControlSnapshot currentSnapshot;
  List<AdminControlAuditLogItem> auditLogs;

  _FakeAdminControlApiService({
    required this.currentSnapshot,
    this.auditLogs = const [],
  }) : super(Dio());

  @override
  Future<SystemControlSnapshot> fetchAdminSnapshot() async => currentSnapshot;

  @override
  Future<List<AdminControlAuditLogItem>> fetchAuditLogs({int limit = 50}) async =>
      auditLogs;

  @override
  Future<SystemControlSnapshot> updateFeatureLock({
    required String featureKey,
    required bool isLocked,
    required FeatureLockStatus lockStatus,
    String? customBadgeLabel,
    String lockTitle = '',
    String lockMessage = '',
    DateTime? estimatedUnlockAt,
    bool allowAdminBypass = true,
    String? reasonNote,
  }) async {
    final updated = currentSnapshot.features.map((f) {
      if (f.featureKey.toUpperCase() != featureKey.toUpperCase()) return f;
      return f.copyWith(
        isLocked: isLocked,
        lockStatus: isLocked ? lockStatus : FeatureLockStatus.unlocked,
        customBadgeLabel: customBadgeLabel,
        lockTitle: lockTitle,
        lockMessage: lockMessage,
        estimatedUnlockAt: estimatedUnlockAt,
        allowAdminBypass: allowAdminBypass,
        updatedAt: DateTime.now(),
      );
    }).toList();
    currentSnapshot = SystemControlSnapshot(
      configVersion: currentSnapshot.configVersion + 1,
      connectedClients: currentSnapshot.connectedClients,
      features: updated,
      plans: currentSnapshot.plans,
      updatedAt: DateTime.now(),
    );
    return currentSnapshot;
  }

  @override
  Future<SystemControlSnapshot> updatePlanPricing({
    required String planCode,
    String? displayName,
    required int basePriceIdr,
    int? originalPriceIdr,
    String? promoBadgeText,
    required int durationDays,
    required bool isActive,
    bool? isHighlighted,
    String? reasonNote,
  }) async {
    final updatedPlans = currentSnapshot.plans.map((p) {
      if (p.planCode.toUpperCase() != planCode.toUpperCase()) return p;
      return DynamicPlanPricingItem(
        planCode: p.planCode,
        targetTier: p.targetTier,
        displayName: displayName ?? p.displayName,
        durationDays: durationDays,
        basePriceIdr: basePriceIdr,
        originalPriceIdr: originalPriceIdr,
        promoBadgeText: promoBadgeText,
        isHighlighted: isHighlighted ?? p.isHighlighted,
        features: p.features,
        isActive: isActive,
        updatedAt: DateTime.now(),
      );
    }).toList();
    currentSnapshot = SystemControlSnapshot(
      configVersion: currentSnapshot.configVersion + 1,
      connectedClients: currentSnapshot.connectedClients,
      features: currentSnapshot.features,
      plans: updatedPlans,
      affiliateConfig: currentSnapshot.affiliateConfig,
      updatedAt: DateTime.now(),
    );
    return currentSnapshot;
  }

  @override
  Future<SystemControlSnapshot> updateAffiliateConfig({
    required bool isProgramActive,
    required int affiliateCommissionPercent,
    int buyerDiscountPercent = 10,
    required bool allowFreeTierAffiliates,
    int? minWithdrawalIdr,
    String? reasonNote,
  }) async {
    currentSnapshot = SystemControlSnapshot(
      configVersion: currentSnapshot.configVersion + 1,
      connectedClients: currentSnapshot.connectedClients,
      features: currentSnapshot.features,
      plans: currentSnapshot.plans,
      affiliateConfig: AffiliateControlConfig(
        isProgramActive: isProgramActive,
        affiliateCommissionPercent: affiliateCommissionPercent,
        buyerDiscountPercent: buyerDiscountPercent,
        allowFreeTierAffiliates: allowFreeTierAffiliates,
        minWithdrawalIdr: minWithdrawalIdr ?? 20000,
      ),
      updatedAt: DateTime.now(),
    );
    return currentSnapshot;
  }
}

const _regularBarista = AuthUser(
  id: 'u-1',
  username: 'barista_id',
  fullName: 'Barista Reguler',
  role: 'user',
  status: 'active',
  tier: 'pro',
  avatarUrl: '',
);

const _superAdmin = AuthUser(
  id: 'a-1',
  username: 'superadmin',
  fullName: 'Superadmin Coffee Labs',
  role: 'admin',
  status: 'active',
  tier: 'business',
  avatarUrl: '',
);

SystemControlSnapshot _snapshotWithStatuses({
  int version = 2,
  FeatureLockStatus? marketplaceStatus,
  FeatureLockStatus? cafeRadarStatus,
  FeatureLockStatus? smartBrewStatus,
  int proPrice = 99000,
  int bizPrice = 249000,
}) {
  final features = SystemControlSnapshot.defaultToolkitFeatures.map((f) {
    if (f.featureKey == 'MARKETPLACE_KOPI' && marketplaceStatus != null) {
      return f.copyWith(
        isLocked: marketplaceStatus != FeatureLockStatus.unlocked,
        lockStatus: marketplaceStatus,
        lockTitle: 'Marketplace Dalam Perbaikan',
        lockMessage: 'Sedang sinkronisasi stok roastery 15 menit.',
      );
    }
    if (f.featureKey == 'CAFE_RADAR' && cafeRadarStatus != null) {
      return f.copyWith(
        isLocked: cafeRadarStatus != FeatureLockStatus.unlocked,
        lockStatus: cafeRadarStatus,
        lockTitle: 'Cafe Radar 2.0 Segera Hadir',
        lockMessage: 'Radar kedai kopi seluruh Nusantara sedang disiapkan.',
      );
    }
    if (f.featureKey == 'SMART_BREW_AI' && smartBrewStatus != null) {
      return f.copyWith(
        isLocked: smartBrewStatus != FeatureLockStatus.unlocked,
        lockStatus: smartBrewStatus,
        lockTitle: 'Pembaruan Smart Brew AI v3',
        lockMessage: 'Model AI ekstraksi terbaru sedang diterapkan.',
      );
    }
    return f;
  }).toList();

  return SystemControlSnapshot(
    configVersion: version,
    connectedClients: 42,
    features: features,
    plans: [
      DynamicPlanPricingItem(
        planCode: 'PRO_LIFETIME',
        targetTier: 'pro',
        displayName: 'Coffee Labs Pro Lifetime',
        durationDays: 36500,
        basePriceIdr: proPrice,
        originalPriceIdr: 490000,
        promoBadgeText: 'FLASH SALE',
        isHighlighted: true,
        isActive: true,
      ),
      DynamicPlanPricingItem(
        planCode: 'BUSINESS_LIFETIME',
        targetTier: 'business',
        displayName: 'Coffee Labs Business Lifetime',
        durationDays: 36500,
        basePriceIdr: bizPrice,
        originalPriceIdr: 1490000,
        promoBadgeText: 'BEST VALUE',
        isHighlighted: false,
        isActive: true,
      ),
    ],
    updatedAt: DateTime.now(),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('FeatureLockStatus exposes exact Coffee Labs palette colors and labels', () {
    expect(FeatureLockStatus.maintenance.accentTextColor, const Color(0xFFDC2626));
    expect(FeatureLockStatus.maintenance.pillBackgroundColor, const Color(0xFFFEF2F2));
    expect(FeatureLockStatus.maintenance.cardBorderColor, const Color(0xFFFCA5A5));
    expect(FeatureLockStatus.maintenance.defaultBadgeLabel, 'MAINTENANCE');

    expect(FeatureLockStatus.comingSoon.accentTextColor, const Color(0xFF4F46E5));
    expect(FeatureLockStatus.comingSoon.pillBackgroundColor, const Color(0xFFEEF2FF));
    expect(FeatureLockStatus.comingSoon.cardBorderColor, const Color(0xFFC7D2FE));
    expect(FeatureLockStatus.comingSoon.defaultBadgeLabel, 'COMING SOON');

    expect(FeatureLockStatus.updated.accentTextColor, const Color(0xFF047857));
    expect(FeatureLockStatus.updated.pillBackgroundColor, const Color(0xFFECFDF5));
    expect(FeatureLockStatus.updated.cardBorderColor, const Color(0xFF6EE7B7));
    expect(FeatureLockStatus.updated.defaultBadgeLabel, 'UPDATED');
  });

  test('SystemControlSyncController enforces monotonic config_version rule', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final ctrl = container.read(systemControlProvider.notifier);
    ctrl.applyIncomingSnapshot(_snapshotWithStatuses(version: 5, proPrice: 79000));
    expect(container.read(systemControlProvider).snapshot.configVersion, 5);
    expect(
      container.read(dynamicPlanPricingProvider('PRO_LIFETIME'))?.basePriceIdr,
      79000,
    );

    // Stale version v3 must be rejected!
    ctrl.applyIncomingSnapshot(_snapshotWithStatuses(version: 3, proPrice: 99000));
    expect(container.read(systemControlProvider).snapshot.configVersion, 5);
    expect(
      container.read(dynamicPlanPricingProvider('PRO_LIFETIME'))?.basePriceIdr,
      79000,
    );
  });

  testWidgets(
    'ToolkitCard renders distinct status colors/labels and strictly blocks non-Admin entry',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(() => _FakeAuthController(_regularBarista)),
        ],
      );
      addTearDown(container.dispose);

      container.read(systemControlProvider.notifier).applyIncomingSnapshot(
            _snapshotWithStatuses(
              version: 3,
              marketplaceStatus: FeatureLockStatus.maintenance,
              cafeRadarStatus: FeatureLockStatus.comingSoon,
              smartBrewStatus: FeatureLockStatus.updated,
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.45,
                padding: const EdgeInsets.all(12),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: const [
                  ToolkitCard(
                    tool: ToolkitItem(
                      featureKey: 'MARKETPLACE_KOPI',
                      title: 'Marketplace Kopi',
                      subtitle: 'Belanja biji kopi',
                      iconType: 'marketplace',
                      primaryColor: Colors.brown,
                      secondaryColor: Colors.orange,
                      gradientColors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                      destination: Scaffold(body: Text('MARKETPLACE_SECRET_DEST')),
                    ),
                  ),
                  ToolkitCard(
                    tool: ToolkitItem(
                      featureKey: 'CAFE_RADAR',
                      title: 'Cafe Radar',
                      subtitle: 'Kedai terdekat',
                      iconType: 'cafe_radar',
                      primaryColor: Colors.indigo,
                      secondaryColor: Colors.blue,
                      gradientColors: [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
                      destination: Scaffold(body: Text('CAFE_RADAR_SECRET_DEST')),
                    ),
                  ),
                  ToolkitCard(
                    tool: ToolkitItem(
                      featureKey: 'SMART_BREW_AI',
                      title: 'Smart Brew AI',
                      subtitle: 'AI racik resep',
                      iconType: 'smart_brew',
                      primaryColor: Colors.teal,
                      secondaryColor: Colors.green,
                      gradientColors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
                      destination: Scaffold(body: Text('SMART_BREW_SECRET_DEST')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all 3 color-coded badges render simultaneously with exact colors
      final maintBadge = tester.widget<Text>(find.text('MAINTENANCE'));
      final comingBadge = tester.widget<Text>(find.text('COMING SOON'));
      final updatedBadge = tester.widget<Text>(find.text('UPDATED'));
      expect(maintBadge.style?.color, const Color(0xFFDC2626));
      expect(comingBadge.style?.color, const Color(0xFF4F46E5));
      expect(updatedBadge.style?.color, const Color(0xFF047857));

      // Non-Admin taps locked card -> shows lock sheet, NEVER enters destination
      await tester.tap(find.text('Marketplace Kopi'));
      await tester.pumpAndSettle();
      expect(find.text('Marketplace Dalam Perbaikan'), findsOneWidget);
      expect(find.text('Masuk Sebagai Admin (QA Bypass)'), findsNothing);
      expect(find.text('MARKETPLACE_SECRET_DEST'), findsNothing);
    },
  );

  testWidgets(
    'Admin user gets QA Bypass button on locked ToolkitCard and can enter destination',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(() => _FakeAuthController(_superAdmin)),
        ],
      );
      addTearDown(container.dispose);

      container.read(systemControlProvider.notifier).applyIncomingSnapshot(
            _snapshotWithStatuses(
              version: 4,
              marketplaceStatus: FeatureLockStatus.maintenance,
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 180,
                height: 120,
                child: ToolkitCard(
                  tool: ToolkitItem(
                    featureKey: 'MARKETPLACE_KOPI',
                    title: 'Marketplace Kopi',
                    subtitle: 'Belanja biji kopi',
                    iconType: 'marketplace',
                    primaryColor: Colors.brown,
                    secondaryColor: Colors.orange,
                    gradientColors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                    destination: Scaffold(body: Text('MARKETPLACE_ADMIN_DEST')),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Marketplace Kopi'));
      await tester.pumpAndSettle();
      expect(find.text('Masuk Sebagai Admin (QA Bypass)'), findsOneWidget);

      await tester.tap(find.text('Masuk Sebagai Admin (QA Bypass)'));
      await tester.pumpAndSettle();
      expect(find.text('MARKETPLACE_ADMIN_DEST'), findsOneWidget);
    },
  );

  testWidgets(
    'ActiveFeatureLockKickoutWatcher shows non-dismissible overlay immediately when Admin locks active screen',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('HOME_TOOLKIT')),
          ),
        ],
      );
      addTearDown(router.dispose);

      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(() => _FakeAuthController(_regularBarista)),
        ],
      );
      addTearDown(container.dispose);

      // Simulate user currently inside MARKETPLACE_KOPI screen
      container
          .read(systemControlProvider.notifier)
          .setActiveFeatureScreen('MARKETPLACE_KOPI');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => ActiveFeatureLockKickoutWatcher(
              router: router,
              child: child ?? const SizedBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kembali ke Barista Toolkit'), findsNothing);

      // Admin pushes real-time MAINTENANCE lock mid-session!
      container.read(systemControlProvider.notifier).applyIncomingSnapshot(
            _snapshotWithStatuses(
              version: 9,
              marketplaceStatus: FeatureLockStatus.maintenance,
            ),
          );
      await tester.pumpAndSettle();

      expect(find.text('Marketplace Dalam Perbaikan'), findsOneWidget);
      expect(find.text('Kembali ke Barista Toolkit'), findsOneWidget);

      // User clicks return button -> active screen cleared & overlay dismissed
      await tester.tap(find.text('Kembali ke Barista Toolkit'));
      await tester.pumpAndSettle();
      expect(find.text('Kembali ke Barista Toolkit'), findsNothing);
      expect(find.text('HOME_TOOLKIT'), findsOneWidget);
    },
  );

  testWidgets(
    'SubscriptionPlanSelectorScreen reflects live Pro & Business price changes immediately',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(systemControlProvider.notifier).applyIncomingSnapshot(
            _snapshotWithStatuses(version: 2, proPrice: 99000, bizPrice: 249000),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: SubscriptionPlanSelectorScreen(initialTier: 'pro'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('99.000'), findsWidgets);

      // Admin updates Pro Lifetime to Rp 79.000 & Business Lifetime to Rp 199.000 in real time!
      container.read(systemControlProvider.notifier).applyIncomingSnapshot(
            _snapshotWithStatuses(version: 3, proPrice: 79000, bizPrice: 199000),
          );
      await tester.pumpAndSettle();

      expect(find.textContaining('79.000'), findsWidgets);
      expect(find.textContaining('199.000'), findsWidgets);
    },
  );

  testWidgets(
    'AdminControlPanelScreen renders all 3 tabs cleanly at 360x780 without RenderFlex overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeApi = _FakeAdminControlApiService(
        currentSnapshot: _snapshotWithStatuses(
          version: 7,
          marketplaceStatus: FeatureLockStatus.maintenance,
          cafeRadarStatus: FeatureLockStatus.comingSoon,
        ),
        auditLogs: [
          AdminControlAuditLogItem(
            id: 'log-1',
            adminEmail: 'superadmin@coffeelabs.id',
            actionCategory: 'FEATURE_LOCK',
            targetKey: 'MARKETPLACE_KOPI',
            previousState: const {'is_locked': false},
            newState: const {'is_locked': true, 'lock_status': 'MAINTENANCE'},
            reasonNote: 'Audit stok',
            configVersionAfter: 7,
            createdAt: DateTime.now(),
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          adminControlApiProvider.overrideWithValue(fakeApi),
          authControllerProvider.overrideWith(() => _FakeAuthController(_superAdmin)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: AdminControlPanelScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tab 1: Feature Locks
      expect(find.text('Admin Control Panel'), findsOneWidget);
      expect(find.text('Lock Semua'), findsOneWidget);
      expect(find.text('Unlock Semua'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tab 2: Dynamic Pricing Pro & Business + Affiliate Control (10% / 20% & Pro / Free)
      await tester.tap(find.text('Harga Pro/Bisnis'));
      await tester.pumpAndSettle();
      expect(find.text('KONTROL AFILIASI'), findsOneWidget);
      expect(find.text('10%'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);
      expect(find.textContaining('Pro & Free'), findsOneWidget);
      expect(find.textContaining('Coffee Labs Pro Lifetime'), findsOneWidget);
      expect(find.textContaining('Simpan & Update Real-Time'), findsWidgets);
      expect(tester.takeException(), isNull);

      // Tab 3: Audit Logs
      await tester.tap(find.text('Audit Log'));
      await tester.pumpAndSettle();
      expect(find.text('MARKETPLACE_KOPI'), findsOneWidget);
      expect(find.textContaining('superadmin@coffeelabs.id'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
