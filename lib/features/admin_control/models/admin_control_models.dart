import 'package:flutter/material.dart';

import '../../qris_billing/domain/qris_billing_models.dart';

/// Status penguncian fitur di Barista Toolkit dengan skema warna unik.
enum FeatureLockStatus {
  unlocked,
  maintenance,
  comingSoon,
  updated;

  static FeatureLockStatus fromApi(String? raw, {bool isLocked = false}) {
    if (!isLocked) return FeatureLockStatus.unlocked;
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'COMING_SOON':
        return FeatureLockStatus.comingSoon;
      case 'UPDATED':
        return FeatureLockStatus.updated;
      case 'MAINTENANCE':
        return FeatureLockStatus.maintenance;
      default:
        return FeatureLockStatus.maintenance;
    }
  }

  String get apiValue {
    switch (this) {
      case FeatureLockStatus.unlocked:
        return 'UNLOCKED';
      case FeatureLockStatus.maintenance:
        return 'MAINTENANCE';
      case FeatureLockStatus.comingSoon:
        return 'COMING_SOON';
      case FeatureLockStatus.updated:
        return 'UPDATED';
    }
  }

  /// Warna teks utama, badge & ikon sesuai matriks arsitektur Coffee Labs.
  Color get accentTextColor {
    switch (this) {
      case FeatureLockStatus.unlocked:
        return const Color(0xFF2A1E17);
      case FeatureLockStatus.maintenance:
        return const Color(0xFFDC2626); // Warm Crimson / Red-Orange
      case FeatureLockStatus.comingSoon:
        return const Color(0xFF4F46E5); // Royal Indigo
      case FeatureLockStatus.updated:
        return const Color(0xFF047857); // Emerald Teal
    }
  }

  Color get pillBackgroundColor {
    switch (this) {
      case FeatureLockStatus.unlocked:
        return const Color(0xFFECFDF5);
      case FeatureLockStatus.maintenance:
        return const Color(0xFFFEF2F2);
      case FeatureLockStatus.comingSoon:
        return const Color(0xFFEEF2FF);
      case FeatureLockStatus.updated:
        return const Color(0xFFECFDF5);
    }
  }

  Color get cardBorderColor {
    switch (this) {
      case FeatureLockStatus.unlocked:
        return const Color(0xFFECE2D6);
      case FeatureLockStatus.maintenance:
        return const Color(0xFFFCA5A5);
      case FeatureLockStatus.comingSoon:
        return const Color(0xFFC7D2FE);
      case FeatureLockStatus.updated:
        return const Color(0xFF6EE7B7);
    }
  }

  String get defaultBadgeLabel {
    switch (this) {
      case FeatureLockStatus.unlocked:
        return 'ACTIVE';
      case FeatureLockStatus.maintenance:
        return 'MAINTENANCE';
      case FeatureLockStatus.comingSoon:
        return 'COMING SOON';
      case FeatureLockStatus.updated:
        return 'UPDATED';
    }
  }

  IconData get statusIcon {
    switch (this) {
      case FeatureLockStatus.unlocked:
        return Icons.check_circle_rounded;
      case FeatureLockStatus.maintenance:
        return Icons.build_circle_rounded;
      case FeatureLockStatus.comingSoon:
        return Icons.rocket_launch_rounded;
      case FeatureLockStatus.updated:
        return Icons.auto_awesome_rounded;
    }
  }

  String defaultTitleFor(String featureName) {
    switch (this) {
      case FeatureLockStatus.unlocked:
        return '$featureName Aktif';
      case FeatureLockStatus.maintenance:
        return '$featureName Sedang Perbaikan';
      case FeatureLockStatus.comingSoon:
        return '$featureName Segera Hadir!';
      case FeatureLockStatus.updated:
        return 'Pembaruan $featureName Diterapkan';
    }
  }

  String get defaultMessage {
    switch (this) {
      case FeatureLockStatus.unlocked:
        return 'Fitur aktif dan siap digunakan.';
      case FeatureLockStatus.maintenance:
        return 'Fitur sedang dalam pemeliharaan terjadwal oleh Admin. Silakan coba kembali sesaat lagi.';
      case FeatureLockStatus.comingSoon:
        return 'Fitur baru ini sedang disiapkan tim Coffee Labs dan akan segera meluncur untuk Anda.';
      case FeatureLockStatus.updated:
        return 'Pembaruan versi terbaru sedang diterapkan agar pengalaman menyeduh makin optimal.';
    }
  }

  String get shortCardFallbackSubtitle {
    switch (this) {
      case FeatureLockStatus.unlocked:
        return '';
      case FeatureLockStatus.maintenance:
        return 'Sedang dalam perbaikan...';
      case FeatureLockStatus.comingSoon:
        return 'Segera hadir untuk Anda!';
      case FeatureLockStatus.updated:
        return 'Pembaruan versi terbaru...';
    }
  }
}

class FeatureControlItem {
  final String featureKey;
  final String displayName;
  final String groupSection;
  final String routePrefix;
  final List<String> apiPathPrefixes;
  final int displayOrder;
  final bool isLocked;
  final FeatureLockStatus lockStatus;
  final String? customBadgeLabel;
  final String lockTitle;
  final String lockMessage;
  final DateTime? estimatedUnlockAt;
  final bool allowAdminBypass;
  final DateTime? updatedAt;

  const FeatureControlItem({
    required this.featureKey,
    required this.displayName,
    required this.groupSection,
    required this.routePrefix,
    this.apiPathPrefixes = const [],
    this.displayOrder = 10,
    this.isLocked = false,
    this.lockStatus = FeatureLockStatus.unlocked,
    this.customBadgeLabel,
    this.lockTitle = '',
    this.lockMessage = '',
    this.estimatedUnlockAt,
    this.allowAdminBypass = true,
    this.updatedAt,
  });

  String get effectiveBadgeLabel {
    final custom = customBadgeLabel?.trim() ?? '';
    return custom.isNotEmpty ? custom.toUpperCase() : lockStatus.defaultBadgeLabel;
  }

  String get effectiveTitle {
    final trimmed = lockTitle.trim();
    return trimmed.isNotEmpty ? trimmed : lockStatus.defaultTitleFor(displayName);
  }

  String get effectiveMessage {
    final trimmed = lockMessage.trim();
    return trimmed.isNotEmpty ? trimmed : lockStatus.defaultMessage;
  }

  String get effectiveCardSubtitle {
    final trimmed = lockMessage.trim();
    return trimmed.isNotEmpty ? trimmed : lockStatus.shortCardFallbackSubtitle;
  }

  bool matchesRoutePath(String path) {
    final normalized = routePrefix.trim();
    if (normalized.isEmpty || normalized == '/') return false;
    return path == normalized || path.startsWith('$normalized/');
  }

  FeatureControlItem copyWith({
    bool? isLocked,
    FeatureLockStatus? lockStatus,
    String? customBadgeLabel,
    bool clearBadge = false,
    String? lockTitle,
    String? lockMessage,
    DateTime? estimatedUnlockAt,
    bool clearEta = false,
    bool? allowAdminBypass,
    DateTime? updatedAt,
  }) {
    return FeatureControlItem(
      featureKey: featureKey,
      displayName: displayName,
      groupSection: groupSection,
      routePrefix: routePrefix,
      apiPathPrefixes: apiPathPrefixes,
      displayOrder: displayOrder,
      isLocked: isLocked ?? this.isLocked,
      lockStatus: lockStatus ?? this.lockStatus,
      customBadgeLabel: clearBadge ? null : (customBadgeLabel ?? this.customBadgeLabel),
      lockTitle: lockTitle ?? this.lockTitle,
      lockMessage: lockMessage ?? this.lockMessage,
      estimatedUnlockAt: clearEta ? null : (estimatedUnlockAt ?? this.estimatedUnlockAt),
      allowAdminBypass: allowAdminBypass ?? this.allowAdminBypass,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory FeatureControlItem.fromJson(Map<String, dynamic> j) {
    final locked = j['is_locked'] == true;
    final rawPrefixes = j['api_path_prefixes'];
    return FeatureControlItem(
      featureKey: (j['feature_key'] ?? '').toString().toUpperCase(),
      displayName: (j['display_name'] ?? '').toString(),
      groupSection: (j['group_section'] ?? 'EKOSISTEM_KOMUNITAS').toString(),
      routePrefix: (j['route_prefix'] ?? '').toString(),
      apiPathPrefixes: rawPrefixes is List
          ? rawPrefixes.map((e) => e.toString()).toList()
          : const [],
      displayOrder: ((j['display_order'] as num?) ?? 10).toInt(),
      isLocked: locked,
      lockStatus: FeatureLockStatus.fromApi(
        j['lock_status']?.toString(),
        isLocked: locked,
      ),
      customBadgeLabel: j['custom_badge_label']?.toString(),
      lockTitle: (j['lock_title'] ?? '').toString(),
      lockMessage: (j['lock_message'] ?? '').toString(),
      estimatedUnlockAt: j['estimated_unlock_at'] != null
          ? DateTime.tryParse(j['estimated_unlock_at'].toString())
          : null,
      allowAdminBypass: j['allow_admin_bypass'] != false,
      updatedAt: j['updated_at'] != null
          ? DateTime.tryParse(j['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'feature_key': featureKey,
        'display_name': displayName,
        'group_section': groupSection,
        'route_prefix': routePrefix,
        'api_path_prefixes': apiPathPrefixes,
        'display_order': displayOrder,
        'is_locked': isLocked,
        'lock_status': lockStatus.apiValue,
        'custom_badge_label': customBadgeLabel,
        'lock_title': lockTitle,
        'lock_message': lockMessage,
        'estimated_unlock_at': estimatedUnlockAt?.toUtc().toIso8601String(),
        'allow_admin_bypass': allowAdminBypass,
        'updated_at': updatedAt?.toUtc().toIso8601String(),
      };
}

class DynamicPlanPricingItem {
  final String planCode;
  final String targetTier;
  final String displayName;
  final int durationDays;
  final int basePriceIdr;
  final int? originalPriceIdr;
  final String? promoBadgeText;
  final bool isHighlighted;
  final List<String> features;
  final bool isActive;
  final DateTime? updatedAt;

  const DynamicPlanPricingItem({
    required this.planCode,
    required this.targetTier,
    required this.displayName,
    required this.durationDays,
    required this.basePriceIdr,
    this.originalPriceIdr,
    this.promoBadgeText,
    this.isHighlighted = false,
    this.features = const [],
    this.isActive = true,
    this.updatedAt,
  });

  bool get isBusiness => targetTier.toLowerCase() == 'business';

  SubscriptionPlanCatalogItem toSubscriptionPlanItem() {
    final fallbackNormal = isBusiness ? 1490000 : 490000;
    return SubscriptionPlanCatalogItem(
      planCode: planCode,
      targetTier: targetTier,
      displayName: displayName,
      durationDays: durationDays,
      basePriceIdr: basePriceIdr,
      normalPriceIdr: (originalPriceIdr != null && originalPriceIdr! > basePriceIdr)
          ? originalPriceIdr!
          : fallbackNormal,
      promoBadgeText: promoBadgeText,
      isHighlighted: isHighlighted,
      features: features.isNotEmpty
          ? features
          : SubscriptionPlanCatalogItem.defaultCatalog
              .firstWhere(
                (p) => p.isBusiness == isBusiness,
                orElse: () => SubscriptionPlanCatalogItem.defaultCatalog.first,
              )
              .features,
      isActive: isActive,
    );
  }

  factory DynamicPlanPricingItem.fromJson(Map<String, dynamic> j) {
    final rawFeatures = j['features'] ?? j['features_json'];
    return DynamicPlanPricingItem(
      planCode: (j['plan_code'] ?? '').toString().toUpperCase(),
      targetTier: (j['target_tier'] ?? 'pro').toString().toLowerCase(),
      displayName: (j['display_name'] ?? '').toString(),
      durationDays: ((j['duration_days'] as num?) ?? 30).toInt(),
      basePriceIdr: ((j['base_price_idr'] as num?) ?? 99000).toInt(),
      originalPriceIdr: (j['original_price_idr'] as num?)?.toInt(),
      promoBadgeText: j['promo_badge_text']?.toString(),
      isHighlighted: j['is_highlighted'] == true,
      features: rawFeatures is List
          ? rawFeatures.map((e) => e.toString()).toList()
          : const [],
      isActive: j['is_active'] != false,
      updatedAt: j['updated_at'] != null
          ? DateTime.tryParse(j['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'plan_code': planCode,
        'target_tier': targetTier,
        'display_name': displayName,
        'duration_days': durationDays,
        'base_price_idr': basePriceIdr,
        'original_price_idr': originalPriceIdr,
        'promo_badge_text': promoBadgeText,
        'is_highlighted': isHighlighted,
        'features': features,
        'is_active': isActive,
        'updated_at': updatedAt?.toUtc().toIso8601String(),
      };
}

class AdminControlAuditLogItem {
  final String id;
  final String adminEmail;
  final String actionCategory;
  final String targetKey;
  final Map<String, dynamic> previousState;
  final Map<String, dynamic> newState;
  final String? reasonNote;
  final int configVersionAfter;
  final DateTime createdAt;

  const AdminControlAuditLogItem({
    required this.id,
    required this.adminEmail,
    required this.actionCategory,
    required this.targetKey,
    required this.previousState,
    required this.newState,
    this.reasonNote,
    required this.configVersionAfter,
    required this.createdAt,
  });

  factory AdminControlAuditLogItem.fromJson(Map<String, dynamic> j) {
    return AdminControlAuditLogItem(
      id: (j['id'] ?? '').toString(),
      adminEmail: (j['admin_email'] ?? 'admin').toString(),
      actionCategory: (j['action_category'] ?? '').toString(),
      targetKey: (j['target_key'] ?? '').toString(),
      previousState: j['previous_state'] is Map
          ? Map<String, dynamic>.from(j['previous_state'] as Map)
          : const {},
      newState: j['new_state'] is Map
          ? Map<String, dynamic>.from(j['new_state'] as Map)
          : const {},
      reasonNote: j['reason_note']?.toString(),
      configVersionAfter: ((j['config_version_after'] as num?) ?? 1).toInt(),
      createdAt: DateTime.tryParse((j['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class SystemControlSnapshot {
  final int configVersion;
  final bool globalMaintenanceMode;
  final String? globalMaintenanceMessage;
  final int connectedClients;
  final Map<String, FeatureControlItem> featuresByKey;
  final List<FeatureControlItem> features;
  final List<DynamicPlanPricingItem> plans;
  final DateTime? updatedAt;

  SystemControlSnapshot({
    required this.configVersion,
    this.globalMaintenanceMode = false,
    this.globalMaintenanceMessage,
    this.connectedClients = 0,
    required this.features,
    required this.plans,
    this.updatedAt,
  }) : featuresByKey = {
          for (final f in features) f.featureKey.toUpperCase(): f,
        };

  factory SystemControlSnapshot.empty() => SystemControlSnapshot(
        configVersion: 0,
        features: defaultToolkitFeatures,
        plans: defaultDynamicPlans,
      );

  FeatureControlItem? featureForKey(String featureKey) =>
      featuresByKey[featureKey.toUpperCase()];

  FeatureControlItem? findLockedFeatureForRoute(String routePath) {
    for (final f in features) {
      if (f.isLocked && f.matchesRoutePath(routePath)) {
        return f;
      }
    }
    return null;
  }

  factory SystemControlSnapshot.fromJson(Map<String, dynamic> j) {
    final rawFeatures = j['features'] as List<dynamic>? ?? const [];
    final rawPlans = j['plans'] as List<dynamic>? ?? const [];
    return SystemControlSnapshot(
      configVersion: ((j['config_version'] as num?) ?? 1).toInt(),
      globalMaintenanceMode: j['global_maintenance_mode'] == true,
      globalMaintenanceMessage: j['global_maintenance_message']?.toString(),
      connectedClients: ((j['connected_clients'] as num?) ?? 0).toInt(),
      features: rawFeatures
          .whereType<Map>()
          .map((e) => FeatureControlItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      plans: rawPlans
          .whereType<Map>()
          .map((e) => DynamicPlanPricingItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      updatedAt: j['updated_at'] != null
          ? DateTime.tryParse(j['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'config_version': configVersion,
        'global_maintenance_mode': globalMaintenanceMode,
        'global_maintenance_message': globalMaintenanceMessage,
        'connected_clients': connectedClients,
        'features': features.map((f) => f.toJson()).toList(),
        'plans': plans.map((p) => p.toJson()).toList(),
        'updated_at': updatedAt?.toUtc().toIso8601String(),
      };

  static const List<FeatureControlItem> defaultToolkitFeatures = [
    FeatureControlItem(featureKey: 'GAME_BREW_3D', displayName: 'Game Brew V60', groupSection: 'LEARNING_BREW', routePrefix: '/toolkit/game-brew', displayOrder: 1),
    FeatureControlItem(featureKey: 'EBOOK_DRM_LIBRARY', displayName: 'Pustaka E-Book DRM', groupSection: 'LEARNING_BREW', routePrefix: '/toolkit/ebooks', displayOrder: 2),
    FeatureControlItem(featureKey: 'LMS_EBOOK_ACADEMY', displayName: 'Akademi Barista LMS', groupSection: 'LEARNING_BREW', routePrefix: '/toolkit/lms', displayOrder: 3),
    FeatureControlItem(featureKey: 'BREW_DOCTOR', displayName: 'Brew Doctor & Kompas', groupSection: 'LEARNING_BREW', routePrefix: '/toolkit/brew-doctor', displayOrder: 4),
    FeatureControlItem(featureKey: 'MARKETPLACE_KOPI', displayName: 'Marketplace Kopi', groupSection: 'EKOSISTEM_KOMUNITAS', routePrefix: '/marketplace', displayOrder: 5),
    FeatureControlItem(featureKey: 'COFFEE_ROASTERY', displayName: 'Coffee Roastery', groupSection: 'EKOSISTEM_KOMUNITAS', routePrefix: '/roasteries', displayOrder: 6),
    FeatureControlItem(featureKey: 'BEANS_RADAR', displayName: 'Beans Radar', groupSection: 'EKOSISTEM_KOMUNITAS', routePrefix: '/bean-radar', displayOrder: 7),
    FeatureControlItem(featureKey: 'CAFE_RADAR', displayName: 'Cafe Radar', groupSection: 'EKOSISTEM_KOMUNITAS', routePrefix: '/cafe-radar', displayOrder: 8),
    FeatureControlItem(featureKey: 'JURNAL_BREW', displayName: 'Jurnal Brew', groupSection: 'EKOSISTEM_KOMUNITAS', routePrefix: '/brew-journal', displayOrder: 9),
    FeatureControlItem(featureKey: 'SOCIAL_COFFEE', displayName: 'Social Coffee', groupSection: 'EKOSISTEM_KOMUNITAS', routePrefix: '/social', displayOrder: 10),
    FeatureControlItem(featureKey: 'FAVORITE_RECIPES', displayName: 'Favorite', groupSection: 'EKOSISTEM_KOMUNITAS', routePrefix: '/favorites', displayOrder: 11),
    FeatureControlItem(featureKey: 'LIVE_BREW_QR', displayName: 'Live Brew QR', groupSection: 'EKOSISTEM_KOMUNITAS', routePrefix: '/livebrew', displayOrder: 12),
    FeatureControlItem(featureKey: 'SMART_BREW_AI', displayName: 'Smart Brew AI', groupSection: 'LAB_EKSTRAKSI_AI', routePrefix: '/toolkit/smart-brew', displayOrder: 13),
    FeatureControlItem(featureKey: 'AI_BEAN_SCANNER', displayName: 'Studio AI & Scanner', groupSection: 'LAB_EKSTRAKSI_AI', routePrefix: '/in-app-trainer', displayOrder: 14),
    FeatureControlItem(featureKey: 'DIAL_IN_ASSISTANT', displayName: 'Asisten Dial-In', groupSection: 'LAB_EKSTRAKSI_AI', routePrefix: '/dial-in', displayOrder: 15),
    FeatureControlItem(featureKey: 'GRINDER_MATRIX', displayName: 'Matriks Grinder', groupSection: 'LAB_EKSTRAKSI_AI', routePrefix: '/toolkit/grinder', displayOrder: 16),
    FeatureControlItem(featureKey: 'FOUR_SIX_CALC', displayName: 'Kalkulator 4:6', groupSection: 'LAB_EKSTRAKSI_AI', routePrefix: '/toolkit/four-six', displayOrder: 17),
    FeatureControlItem(featureKey: 'TDS_EXTRACTION', displayName: 'Ekstraksi & TDS', groupSection: 'LAB_EKSTRAKSI_AI', routePrefix: '/toolkit/tds', displayOrder: 18),
    FeatureControlItem(featureKey: 'WATER_CHEMISTRY', displayName: 'Kimia Air Seduh', groupSection: 'SAINS_KOPI', routePrefix: '/toolkit/water', displayOrder: 19),
    FeatureControlItem(featureKey: 'BEAN_FRESHNESS', displayName: 'Kesegaran Biji', groupSection: 'SAINS_KOPI', routePrefix: '/toolkit/freshness', displayOrder: 20),
    FeatureControlItem(featureKey: 'SMART_SCALE', displayName: 'Smart Scale Brew', groupSection: 'SAINS_KOPI', routePrefix: '/smart-scale', displayOrder: 21),
    FeatureControlItem(featureKey: 'CUPPING_FLAVOR', displayName: 'Cupping Flavour', groupSection: 'SAINS_KOPI', routePrefix: '/toolkit/cupping', displayOrder: 22),
    FeatureControlItem(featureKey: 'AFFILIATE_PROGRAM', displayName: 'Program Afiliasi 20%', groupSection: 'MONETISASI_BISNIS', routePrefix: '/affiliate', displayOrder: 23),
    FeatureControlItem(featureKey: 'BUSINESS_POS_KIOSK', displayName: 'POS Kasir & AOD Kiosk', groupSection: 'MONETISASI_BISNIS', routePrefix: '/business', displayOrder: 24),
  ];

  static const List<DynamicPlanPricingItem> defaultDynamicPlans = [
    DynamicPlanPricingItem(
      planCode: 'PRO_LIFETIME',
      targetTier: 'pro',
      displayName: 'Coffee Labs Pro Lifetime',
      durationDays: 36500,
      basePriceIdr: 99000,
      originalPriceIdr: 490000,
      promoBadgeText: 'POPULER',
      isHighlighted: true,
      isActive: true,
    ),
    DynamicPlanPricingItem(
      planCode: 'BUSINESS_LIFETIME',
      targetTier: 'business',
      displayName: 'Coffee Labs Business Lifetime',
      durationDays: 36500,
      basePriceIdr: 249000,
      originalPriceIdr: 1490000,
      promoBadgeText: 'KAFE & ROASTERY',
      isHighlighted: false,
      isActive: true,
    ),
  ];
}
