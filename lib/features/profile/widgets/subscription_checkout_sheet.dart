import 'package:flutter/material.dart';
import '../../../models/subscription_plan.dart';
import '../../qris_billing/presentation/screens/subscription_plan_selector_screen.dart';

/// Entry point terpadu pembelian lisensi Coffee Labs Pro & Business.
/// Menggunakan sistem **QRIS Dinamis Zero-Gateway Livin' Merchant (`Coffeelabs`)**
/// dengan sinkronisasi real-time WebSocket & aktivasi akun instan tanpa simulasi.
class SubscriptionCheckoutSheet extends StatelessWidget {
  final SubscriptionPlan initialPlan;

  const SubscriptionCheckoutSheet({
    super.key,
    this.initialPlan = SubscriptionPlan.pro,
  });

  static Future<void> show(BuildContext context, {SubscriptionPlan? plan}) {
    final targetTier =
        (plan ?? SubscriptionPlan.pro).tier == SubscriptionTier.business
            ? 'business'
            : 'pro';
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => SubscriptionPlanSelectorScreen(
          initialTier: targetTier,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetTier =
        initialPlan.tier == SubscriptionTier.business ? 'business' : 'pro';
    return SubscriptionPlanSelectorScreen(initialTier: targetTier);
  }
}
