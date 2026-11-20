import 'dart:ui';

enum LiveBrewMirrorPhase {
  seatIdleBranded('SEAT_IDLE_BRANDED', 'Siap Menerima Pesanan Kopi', 0),
  posOrderQueued('POS_ORDER_QUEUED', 'Pesanan Masuk Antrean Brew Bar', 1),
  brewerSelectingRecipe('BREWER_SELECTING_RECIPE', 'Barista Memilih Metode & Resep', 2),
  brewerSelectingBean('BREWER_SELECTING_BEAN', 'Barista Memilih Biji Kopi', 3),
  preBrewCalibrated('PRE_BREW_CALIBRATED', 'Resep & Kopi Siap — Menunggu Tuangan', 4),
  brewingActive('BREWING_ACTIVE', 'Sedang Diseduh Live (1:1 Sync)', 5),
  brewingPaused('BREWING_PAUSED', 'Seduhan Dijeda Sementara', 5),
  servingReadyPassport('SERVING_READY_PASSPORT', 'Siap Disajikan! Digital Cup Passport', 6),
  archived('ARCHIVED', 'Sesi Seduhan Selesai', 7);

  final String apiValue;
  final String labelId;
  final int progressStep;

  const LiveBrewMirrorPhase(this.apiValue, this.labelId, this.progressStep);

  static LiveBrewMirrorPhase fromApi(String? raw) {
    final upper = (raw ?? '').trim().toUpperCase();
    for (final v in values) {
      if (v.apiValue == upper) return v;
    }
    return LiveBrewMirrorPhase.brewerSelectingRecipe;
  }
}

enum LiveTimerStatus {
  idle('IDLE'),
  running('RUNNING'),
  paused('PAUSED'),
  finished('FINISHED');

  final String apiValue;
  const LiveTimerStatus(this.apiValue);

  static LiveTimerStatus fromApi(String? raw) {
    final upper = (raw ?? '').trim().toUpperCase();
    for (final v in values) {
      if (v.apiValue == upper) return v;
    }
    return LiveTimerStatus.idle;
  }
}

enum CafeSeatKind {
  meja('MEJA', 'Meja'),
  kursiBar('KURSI_BAR', 'Kursi Bar'),
  vipRoom('VIP_ROOM', 'VIP Room'),
  outdoor('OUTDOOR', 'Outdoor'),
  takeawayCounter('TAKEAWAY_COUNTER', 'Takeaway');

  final String apiValue;
  final String labelId;
  const CafeSeatKind(this.apiValue, this.labelId);

  static CafeSeatKind fromApi(String? raw) {
    final upper = (raw ?? '').trim().toUpperCase();
    for (final v in values) {
      if (v.apiValue == upper) return v;
    }
    return CafeSeatKind.meja;
  }
}

class BusinessBrandingModel {
  final String storeId;
  final String cafeSlug;
  final String cafeDisplayName;
  final String? logoCloudinaryUrl;
  final String primaryColorHex;
  final String accentColorHex;
  final String welcomeMessage;
  final String? wifiSsid;
  final String? wifiPassword;
  final String? instagramHandle;
  final bool showPosQueuePosition;
  final bool showLiveBeanDetails;

  const BusinessBrandingModel({
    required this.storeId,
    required this.cafeSlug,
    required this.cafeDisplayName,
    this.logoCloudinaryUrl,
    this.primaryColorHex = '#12100E',
    this.accentColorHex = '#D4A373',
    this.welcomeMessage =
        'Selamat menikmati seduhan segar kami! Pantau proses seduhan Anda secara live di sini.',
    this.wifiSsid,
    this.wifiPassword,
    this.instagramHandle,
    this.showPosQueuePosition = true,
    this.showLiveBeanDetails = true,
  });

  Color get primaryColor => _parseHex(primaryColorHex, const Color(0xFF12100E));
  Color get accentColor => _parseHex(accentColorHex, const Color(0xFFD4A373));

  static Color _parseHex(String raw, Color fallback) {
    final hex = raw.trim().replaceFirst('#', '');
    if (hex.length == 6) {
      final parsed = int.tryParse('FF$hex', radix: 16);
      if (parsed != null) return Color(parsed);
    }
    return fallback;
  }

  factory BusinessBrandingModel.fromJson(Map<String, dynamic> j) {
    return BusinessBrandingModel(
      storeId: (j['store_id'] ?? '').toString(),
      cafeSlug: (j['cafe_slug'] ?? '').toString(),
      cafeDisplayName: (j['cafe_display_name'] ?? 'Coffee Labs Bar').toString(),
      logoCloudinaryUrl: j['logo_cloudinary_url']?.toString(),
      primaryColorHex: (j['primary_color_hex'] ?? '#12100E').toString(),
      accentColorHex: (j['accent_color_hex'] ?? '#D4A373').toString(),
      welcomeMessage: (j['welcome_message'] ??
              'Selamat menikmati seduhan segar kami!')
          .toString(),
      wifiSsid: j['wifi_ssid']?.toString(),
      wifiPassword: j['wifi_password']?.toString(),
      instagramHandle: j['instagram_handle']?.toString(),
      showPosQueuePosition: j['show_pos_queue_position'] != false,
      showLiveBeanDetails: j['show_live_bean_details'] != false,
    );
  }
}

class CafeSeatModel {
  final String id;
  final String storeId;
  final CafeSeatKind seatKind;
  final String seatLabel;
  final String seatSlug;
  final String zoneArea;
  final int capacityPersons;
  final String numericFallbackCode;
  final String brandedUrl;
  final String deepLinkUrl;
  final String? activeLiveSessionId;
  final String? activePosOrderId;
  final String? activePosOrderNumber;
  final String? activePosOrderStatus;
  final int qrScanCount;
  final bool isActive;

  const CafeSeatModel({
    required this.id,
    required this.storeId,
    required this.seatKind,
    required this.seatLabel,
    required this.seatSlug,
    required this.zoneArea,
    required this.capacityPersons,
    required this.numericFallbackCode,
    required this.brandedUrl,
    required this.deepLinkUrl,
    this.activeLiveSessionId,
    this.activePosOrderId,
    this.activePosOrderNumber,
    this.activePosOrderStatus,
    this.qrScanCount = 0,
    this.isActive = true,
  });

  factory CafeSeatModel.fromJson(Map<String, dynamic> j) {
    return CafeSeatModel(
      id: (j['id'] ?? '').toString(),
      storeId: (j['store_id'] ?? '').toString(),
      seatKind: CafeSeatKind.fromApi(j['seat_kind']?.toString()),
      seatLabel: (j['seat_label'] ?? 'Meja 01').toString(),
      seatSlug: (j['seat_slug'] ?? 'meja-01').toString(),
      zoneArea: (j['zone_area'] ?? 'Main Area').toString(),
      capacityPersons: ((j['capacity_persons'] as num?) ?? 2).toInt(),
      numericFallbackCode: (j['numeric_fallback_code'] ?? '').toString(),
      brandedUrl: (j['branded_url'] ?? '').toString(),
      deepLinkUrl: (j['deep_link_url'] ?? '').toString(),
      activeLiveSessionId: j['active_live_session_id']?.toString(),
      activePosOrderId: j['active_pos_order_id']?.toString(),
      activePosOrderNumber: j['active_pos_order_number']?.toString(),
      activePosOrderStatus: j['active_pos_order_status']?.toString(),
      qrScanCount: ((j['qr_scan_count'] as num?) ?? 0).toInt(),
      isActive: j['is_active'] != false,
    );
  }
}

class PosOrderProgressModel {
  final String? posOrderId;
  final String posOrderNumber;
  final String posOrderStatus;
  final int queuePositionAhead;
  final String itemsSummary;
  final String customerName;

  const PosOrderProgressModel({
    this.posOrderId,
    required this.posOrderNumber,
    required this.posOrderStatus,
    required this.queuePositionAhead,
    required this.itemsSummary,
    required this.customerName,
  });

  factory PosOrderProgressModel.fromJson(Map<String, dynamic> j) {
    return PosOrderProgressModel(
      posOrderId: j['pos_order_id']?.toString(),
      posOrderNumber: (j['pos_order_number'] ?? '').toString(),
      posOrderStatus: (j['pos_order_status'] ?? 'QUEUED').toString(),
      queuePositionAhead: ((j['queue_position_ahead'] as num?) ?? 0).toInt(),
      itemsSummary: (j['items_summary'] ?? 'Specialty Coffee').toString(),
      customerName: (j['customer_name'] ?? 'Pelanggan').toString(),
    );
  }
}

class LiveSessionMirrorSnapshot {
  final String sessionId;
  final String shareCode;
  final String shareUrl;
  final String deepLinkUrl;
  final bool isBusinessSession;
  final String? storeId;
  final String? seatId;
  final String? posOrderId;
  final String? posOrderNumber;
  final String? posOrderStatus;
  final String brewerDisplayName;
  final String? brewerAvatarUrl;
  final String customerName;
  final LiveBrewMirrorPhase phase;
  final String phaseLabelId;
  final int stateVersion;
  final String? selectedMethodId;
  final String? selectedMethodName;
  final String? selectedRecipeId;
  final String? selectedRecipeTitle;
  final Map<String, dynamic> recipeSnapshot;
  final String? selectedBeanId;
  final Map<String, dynamic> beanSnapshot;
  final LiveTimerStatus timerStatus;
  final int timerAccumulatedMs;
  final int? timerAnchorServerMs;
  final int currentStepIndex;
  final double currentWeightG;
  final double currentFlowRateMlS;
  final double currentTempC;
  final int cheersCount;
  final int activeViewersCount;
  final int serverEpochMs;

  const LiveSessionMirrorSnapshot({
    required this.sessionId,
    required this.shareCode,
    required this.shareUrl,
    required this.deepLinkUrl,
    this.isBusinessSession = false,
    this.storeId,
    this.seatId,
    this.posOrderId,
    this.posOrderNumber,
    this.posOrderStatus,
    required this.brewerDisplayName,
    this.brewerAvatarUrl,
    required this.customerName,
    required this.phase,
    required this.phaseLabelId,
    required this.stateVersion,
    this.selectedMethodId,
    this.selectedMethodName,
    this.selectedRecipeId,
    this.selectedRecipeTitle,
    this.recipeSnapshot = const {},
    this.selectedBeanId,
    this.beanSnapshot = const {},
    required this.timerStatus,
    required this.timerAccumulatedMs,
    this.timerAnchorServerMs,
    this.currentStepIndex = 0,
    this.currentWeightG = 0.0,
    this.currentFlowRateMlS = 0.0,
    this.currentTempC = 91.0,
    this.cheersCount = 0,
    this.activeViewersCount = 0,
    required this.serverEpochMs,
  });

  List<Map<String, dynamic>> get recipeSteps {
    final raw = recipeSnapshot['steps'];
    if (raw is List) {
      return raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    return const [];
  }

  int get targetDurationSeconds {
    final explicit = (recipeSnapshot['totalTimeSeconds'] as num?)?.toInt();
    if (explicit != null && explicit > 0) return explicit;
    var sum = 0;
    for (final s in recipeSteps) {
      sum += ((s['durationSeconds'] ?? s['duration'] ?? 30) as num).toInt();
    }
    return sum > 0 ? sum : 150;
  }

  double get targetDoseG =>
      ((recipeSnapshot['coffeeWeightGrams'] as num?) ?? 15.0).toDouble();

  double get targetWaterMl =>
      ((recipeSnapshot['totalWaterWeightGrams'] as num?) ?? 225.0).toDouble();

  factory LiveSessionMirrorSnapshot.fromJson(Map<String, dynamic> j) {
    final phase = LiveBrewMirrorPhase.fromApi(j['phase']?.toString());
    return LiveSessionMirrorSnapshot(
      sessionId: (j['session_id'] ?? '').toString(),
      shareCode: (j['share_code'] ?? '').toString(),
      shareUrl: (j['share_url'] ?? '').toString(),
      deepLinkUrl: (j['deep_link_url'] ?? '').toString(),
      isBusinessSession: j['is_business_session'] == true,
      storeId: j['store_id']?.toString(),
      seatId: j['seat_id']?.toString(),
      posOrderId: j['pos_order_id']?.toString(),
      posOrderNumber: j['pos_order_number']?.toString(),
      posOrderStatus: j['pos_order_status']?.toString(),
      brewerDisplayName: (j['brewer_display_name'] ?? 'Barista Coffee Labs').toString(),
      brewerAvatarUrl: j['brewer_avatar_url']?.toString(),
      customerName: (j['customer_name'] ?? 'Tamu Coffee Labs').toString(),
      phase: phase,
      phaseLabelId: (j['phase_label_id'] ?? phase.labelId).toString(),
      stateVersion: ((j['state_version'] as num?) ?? 1).toInt(),
      selectedMethodId: j['selected_method_id']?.toString(),
      selectedMethodName: j['selected_method_name']?.toString(),
      selectedRecipeId: j['selected_recipe_id']?.toString(),
      selectedRecipeTitle: j['selected_recipe_title']?.toString(),
      recipeSnapshot: j['recipe_snapshot_json'] is Map
          ? (j['recipe_snapshot_json'] as Map).cast<String, dynamic>()
          : const {},
      selectedBeanId: j['selected_bean_id']?.toString(),
      beanSnapshot: j['bean_snapshot_json'] is Map
          ? (j['bean_snapshot_json'] as Map).cast<String, dynamic>()
          : const {},
      timerStatus: LiveTimerStatus.fromApi(j['timer_status']?.toString()),
      timerAccumulatedMs: ((j['timer_accumulated_ms'] as num?) ?? 0).toInt(),
      timerAnchorServerMs: (j['timer_anchor_server_ms'] as num?)?.toInt(),
      currentStepIndex: ((j['current_step_index'] as num?) ?? 0).toInt(),
      currentWeightG: ((j['current_weight_g'] as num?) ?? 0.0).toDouble(),
      currentFlowRateMlS: ((j['current_flow_rate_ml_s'] as num?) ?? 0.0).toDouble(),
      currentTempC: ((j['current_temp_c'] as num?) ?? 91.0).toDouble(),
      cheersCount: ((j['cheers_count'] as num?) ?? 0).toInt(),
      activeViewersCount: ((j['active_viewers_count'] as num?) ?? 0).toInt(),
      serverEpochMs: ((j['server_epoch_ms'] as num?) ??
              DateTime.now().millisecondsSinceEpoch)
          .toInt(),
    );
  }
}

class BrandedSeatResolution {
  final String resolutionKind;
  final BusinessBrandingModel? branding;
  final CafeSeatModel? seat;
  final PosOrderProgressModel? posOrderProgress;
  final LiveSessionMirrorSnapshot? activeBrewSession;
  final int serverEpochMs;

  const BrandedSeatResolution({
    required this.resolutionKind,
    this.branding,
    this.seat,
    this.posOrderProgress,
    this.activeBrewSession,
    required this.serverEpochMs,
  });

  factory BrandedSeatResolution.fromJson(Map<String, dynamic> j) {
    return BrandedSeatResolution(
      resolutionKind: (j['resolution_kind'] ?? 'SEAT_IDLE_BRANDED').toString(),
      branding: j['branding'] is Map
          ? BusinessBrandingModel.fromJson((j['branding'] as Map).cast<String, dynamic>())
          : null,
      seat: j['seat'] is Map
          ? CafeSeatModel.fromJson((j['seat'] as Map).cast<String, dynamic>())
          : null,
      posOrderProgress: j['pos_order_progress'] is Map
          ? PosOrderProgressModel.fromJson(
              (j['pos_order_progress'] as Map).cast<String, dynamic>(),
            )
          : null,
      activeBrewSession: j['active_brew_session'] is Map
          ? LiveSessionMirrorSnapshot.fromJson(
              (j['active_brew_session'] as Map).cast<String, dynamic>(),
            )
          : null,
      serverEpochMs: ((j['server_epoch_ms'] as num?) ??
              DateTime.now().millisecondsSinceEpoch)
          .toInt(),
    );
  }
}
