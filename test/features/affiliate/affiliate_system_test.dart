import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coffee_hub_mobile/features/affiliate/data/affiliate_api_service.dart';
import 'package:coffee_hub_mobile/features/affiliate/models/affiliate_models.dart';
import 'package:coffee_hub_mobile/features/affiliate/presentation/screens/admin_affiliate_payout_queue_screen.dart';
import 'package:coffee_hub_mobile/features/affiliate/presentation/screens/affiliate_hub_screen.dart';
import 'package:coffee_hub_mobile/features/affiliate/presentation/widgets/affiliate_profile_launcher_card.dart';
import 'package:coffee_hub_mobile/features/qris_billing/domain/services/emvco_qris_converter.dart';
import 'package:coffee_hub_mobile/features/qris_billing/presentation/screens/subscription_plan_selector_screen.dart';

class _FakeAffiliateApiService extends AffiliateApiService {
  final AffiliateDashboardModel dashboard;
  final List<AdminWithdrawalItem> adminQueue;

  _FakeAffiliateApiService({
    required this.dashboard,
    this.adminQueue = const [],
  }) : super(Dio());

  @override
  Future<AffiliateDashboardModel> fetchMyDashboard() async => dashboard;

  @override
  Future<List<AdminWithdrawalItem>> fetchAdminQueue({String? status}) async =>
      adminQueue;

  @override
  Future<ValidatedReferralPreview> validateReferralCode({
    required String code,
    required String planCode,
  }) async {
    final isBiz = planCode.toUpperCase().contains('BUSINESS');
    final base = isBiz ? 249000 : 99000;
    final disc = (base * 1000) ~/ 10000;
    return ValidatedReferralPreview(
      valid: true,
      normalizedCode: code.trim().toUpperCase(),
      referrerDisplayName: 'Barista Budi',
      buyerDiscountBps: 1000,
      buyerDiscountIdr: disc,
      basePriceIdr: base,
      finalBasePriceIdr: base - disc,
      affiliateCommissionBps: 2000,
      affiliateCommissionIdr: isBiz ? 50000 : 20000,
    );
  }
}

void main() {
  test(
    'EMVCo resilient invoice applies 10% referral discount before CRC-16 lock',
    () {
      final inv = EmvcoQrisConverter.buildResilientLifetimeInvoice(
        planCode: 'PRO_LIFETIME',
        explicitUniqueCode: 240,
        appliedReferralCode: 'BARISTABUDI',
        discountIdr: 9900,
      );

      expect(inv.baseAmountIdr, 89100);
      expect(inv.buyerDiscountIdr, 9900);
      expect(inv.appliedReferralCode, 'BARISTABUDI');
      expect(inv.totalPayableIdr, 89340);
      expect(
        EmvcoQrisConverter.verifyQrisCrc16(inv.dynamicQrisPayload),
        isTrue,
      );
      expect(inv.dynamicQrisPayload.contains('540589340'), isTrue);
    },
  );

  testWidgets(
    'AffiliateHubScreen renders Pro-Upgrade Gate for Trial user at 360x780 with 0 overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final fakeApi = _FakeAffiliateApiService(
        dashboard: const AffiliateDashboardModel(
          isEligiblePro: false,
          currentTier: 'trial',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            affiliateApiServiceProvider.overrideWithValue(fakeApi),
          ],
          child: const MaterialApp(home: AffiliateHubScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('KHUSUS AKUN PRO & BUSINESS'), findsOneWidget);
      expect(
        find.text('Upgrade ke Pro (Rp 99.000) & Aktifkan Afiliasi'),
        findsOneWidget,
      );
      expect(find.textContaining('Dinamis'), findsNothing);
      expect(find.textContaining('Lifetime'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AffiliateHubScreen renders Pro Wallet, Referral Code, Withdrawal Sheet & Tabs at 360x780 with 0 overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final fakeApi = _FakeAffiliateApiService(
        dashboard: AffiliateDashboardModel(
          isEligiblePro: true,
          currentTier: 'pro',
          wallet: const AffiliateWalletModel(
            affiliateCode: 'CL-BUDI7X2K',
            shareLink: 'https://coffeelabs.id/join?ref=CL-BUDI7X2K',
            isCustomCodeClaimed: false,
            isAffiliateActive: true,
            availableBalanceIdr: 140000,
            lockedWithdrawalIdr: 100000,
            totalEarnedIdr: 240000,
            totalWithdrawnIdr: 0,
            totalSuccessfulReferrals: 8,
            savedPayoutChannel: 'BANK_BCA',
            savedAccountNumber: '1234567890',
            savedAccountHolderName: 'Budi Santoso',
          ),
          recentConversions: [
            AffiliateConversionItem(
              id: 'conv-1',
              buyerUsername: 'barista_andi',
              buyerFullName: 'Andi',
              planCode: 'PRO_LIFETIME',
              commissionEarnedIdr: 20000,
              buyerDiscountIdr: 9900,
              createdAt: DateTime(2026, 11, 19, 10, 30),
            ),
          ],
          recentWithdrawals: [
            AffiliateWithdrawalItem(
              id: 'wd-1',
              ticketNumber: 'WD-20261119-001',
              requestedAmountIdr: 100000,
              adminFeeIdr: 0,
              netTransferAmountIdr: 100000,
              payoutChannel: 'BANK_BCA',
              bankOrWalletLabel: 'BCA',
              accountNumber: '1234567890',
              accountHolderName: 'Budi Santoso',
              status: 'PENDING_ADMIN_REVIEW',
              slaDeadlineAt: DateTime(2026, 11, 20, 10, 30),
              createdAt: DateTime(2026, 11, 19, 10, 30),
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            affiliateApiServiceProvider.overrideWithValue(fakeApi),
          ],
          child: const MaterialApp(home: AffiliateHubScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SALDO AFILIASI TERSEDIA'), findsOneWidget);
      expect(find.text('Rp 140.000'), findsOneWidget);
      expect(find.text('CL-BUDI7X2K'), findsOneWidget);
      expect(find.text('Tarik Saldo ke Bank / E-Wallet'), findsOneWidget);
      expect(find.textContaining('@barista_andi'), findsOneWidget);

      // Switch to Riwayat Penarikan tab and verify 0 overflow
      await tester.tap(find.text('Riwayat Penarikan (1)'));
      await tester.pumpAndSettle();
      expect(find.text('WD-20261119-001 • BCA'), findsOneWidget);
      expect(find.text('Menunggu ACC (1×24 Jam Kerja)'), findsOneWidget);

      // Open Withdrawal BottomSheet and verify 0 overflow
      await tester.tap(find.text('Tarik Saldo ke Bank / E-Wallet'));
      await tester.pumpAndSettle();
      expect(find.text('Tarik Saldo Afiliasi'), findsOneWidget);
      expect(find.text('Ajukan Penarikan Saldo'), findsOneWidget);

      expect(find.textContaining('Dinamis'), findsNothing);
      expect(find.textContaining('Lifetime'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AdminAffiliatePayoutQueueScreen renders payout queue card cleanly at 360x780 with 0 overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final fakeApi = _FakeAffiliateApiService(
        dashboard: const AffiliateDashboardModel(
          isEligiblePro: true,
          currentTier: 'admin',
        ),
        adminQueue: [
          AdminWithdrawalItem(
            id: 'wd-adm-1',
            ticketNumber: 'WD-20261119-999',
            userId: 'usr-1',
            affiliateUsername: 'budi_barista',
            affiliateFullName: 'Budi Santoso',
            affiliateCode: 'BARISTABUDI',
            requestedAmountIdr: 250000,
            netTransferAmountIdr: 250000,
            payoutChannel: 'BANK_BCA',
            bankOrWalletLabel: 'BCA',
            accountNumber: '8821902311',
            accountHolderName: 'Budi Santoso',
            status: 'PENDING_ADMIN_REVIEW',
            slaDeadlineAt: DateTime.now().add(const Duration(hours: 18)),
            createdAt: DateTime.now(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            affiliateApiServiceProvider.overrideWithValue(fakeApi),
          ],
          child: const MaterialApp(home: AdminAffiliatePayoutQueueScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Panel Admin ACC Penarikan'), findsOneWidget);
      expect(find.text('Pending ACC'), findsOneWidget);
      expect(find.text('Salin Rek'), findsOneWidget);
      expect(find.text('Salin Nominal'), findsOneWidget);
      expect(find.text('ACC & Upload Bukti'), findsOneWidget);
      expect(find.text('Tolak'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'SubscriptionPlanSelectorScreen applies 10% referral discount cleanly at 360x780 with 0 overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final fakeApi = _FakeAffiliateApiService(
        dashboard: const AffiliateDashboardModel(
          isEligiblePro: false,
          currentTier: 'trial',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            affiliateApiServiceProvider.overrideWithValue(fakeApi),
          ],
          child: const MaterialApp(
            home: SubscriptionPlanSelectorScreen(initialTier: 'pro'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.scrollUntilVisible(
        input,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(input, 'BARISTABUDI');
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      expect(
        find.text('Kode BARISTABUDI aktif • Hemat Rp 9.900 (10%)'),
        findsOneWidget,
      );
      expect(find.text('Rp 89.100'), findsOneWidget);
      expect(find.textContaining('Dinamis'), findsNothing);
      expect(find.textContaining('Lifetime'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AffiliateProfileLauncherCard renders Pro & Trial badges cleanly at 360x780',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  AffiliateProfileLauncherCard(isProEligible: true),
                  SizedBox(height: 12),
                  AffiliateProfileLauncherCard(isProEligible: false),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Program Afiliasi 20%'), findsNWidgets(2));
      expect(find.text('KOMISI 20%'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
