import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/monitoring/data/telemetry_batch_outbox_service.dart';
import 'package:coffee_hub_mobile/features/monitoring/domain/monitoring_models.dart';
import 'package:coffee_hub_mobile/features/monitoring/presentation/widgets/account_360_dossier_sheet.dart';

void main() {
  group('Monitoring Telemetry Collector & Models', () {
    test('mapRouteToFeature classifies routes to accurate feature buckets', () {
      expect(TelemetryBatchOutboxService.mapRouteToFeature('/brew/timer'), 'brew_timer');
      expect(TelemetryBatchOutboxService.mapRouteToFeature('/social/clubs/123'), 'coffee_club');
      expect(TelemetryBatchOutboxService.mapRouteToFeature('/social/explore'), 'social_coffee');
      expect(TelemetryBatchOutboxService.mapRouteToFeature('/bean-radar'), 'ai_scanner');
      expect(TelemetryBatchOutboxService.mapRouteToFeature('/in-app-trainer'), 'ai_scanner');
      expect(TelemetryBatchOutboxService.mapRouteToFeature('/business/aod-showcase'), 'aod_kiosk');
      expect(TelemetryBatchOutboxService.mapRouteToFeature('/recipes'), 'recipe_lab');
      expect(TelemetryBatchOutboxService.mapRouteToFeature('/marketplace'), 'marketplace');
      expect(TelemetryBatchOutboxService.mapRouteToFeature('/'), 'general');
    });

    test('PlatformOverviewDto & Account360DossierDto parse backend JSON contract cleanly', () {
      final ov = PlatformOverviewDto.fromJson({
        'online_now': 4,
        'total_accounts': 14,
        'trial_accounts': 12,
        'pro_accounts': 1,
        'business_accounts': 1,
        'dau_today': 6,
        'wau_7d': 11,
        'mau_30d': 14,
        'stickiness_pct': 42.9,
        'avg_today_screen_time_sec': 540,
        'total_brews_7d': 29,
        'at_risk_high_count': 2,
        'dormant_count': 1,
        'feature_adoption': [
          {
            'feature_key': 'brew_timer',
            'label': 'Brew Timer & Pour Guidance',
            'active_users_7d': 9,
            'adoption_percent': 81.8,
            'total_minutes_7d': 125,
          }
        ],
        'cohorts': [],
        'top_brew_recipes': [],
      });

      expect(ov.onlineNow, 4);
      expect(ov.totalAccounts, 14);
      expect(ov.stickinessPct, 42.9);
      expect(ov.featureAdoption.first.featureKey, 'brew_timer');
      expect(Account360DossierSheet.formatDuration(3725), '1j 2m');
      expect(Account360DossierSheet.formatDuration(95), '1m 35s');
    });
  });
}
