import 'dart:math' as math;

enum LiveBrewStage {
  queuedAssigned('QUEUED_ASSIGNED', 'Pesanan Diterima di Brew Bar', 0),
  grindingDose('GRINDING_DOSE', 'Menimbang & Menggiling Biji Kopi', 1),
  filterRinsePreheat('FILTER_RINSE_PREHEAT', 'Membilas Filter & Pemanasan Server', 2),
  bloomingDegassing('BLOOMING_DEGASSING', 'Tahap 1: Blooming & Pelepasan CO2', 3),
  activePouring('ACTIVE_POURING', 'Tahap 2-3: Ekstraksi Aroma & Sweetness', 4),
  drawdownSwirl('DRAWDOWN_SWIRL', 'Tahap Akhir: Gentle Swirl & Drawdown', 5),
  readyToServe('READY_TO_SERVE', 'Kopi Anda Siap Disajikan!', 6);

  final String apiValue;
  final String labelId;
  final int stepIndex;

  const LiveBrewStage(this.apiValue, this.labelId, this.stepIndex);

  static LiveBrewStage fromApi(String? raw) {
    final upper = (raw ?? '').trim().toUpperCase();
    for (final val in values) {
      if (val.apiValue == upper) return val;
    }
    return LiveBrewStage.queuedAssigned;
  }
}

class LiveBrewCurvePoint {
  final int tMs;
  final double wG;
  final double flow;
  final double tempC;

  const LiveBrewCurvePoint({
    required this.tMs,
    required this.wG,
    required this.flow,
    required this.tempC,
  });

  factory LiveBrewCurvePoint.fromJson(Map<String, dynamic> j) => LiveBrewCurvePoint(
        tMs: (j['t_ms'] as num?)?.toInt() ?? 0,
        wG: (j['w_g'] as num?)?.toDouble() ?? 0.0,
        flow: (j['flow'] as num?)?.toDouble() ?? 0.0,
        tempC: (j['temp_c'] as num?)?.toDouble() ?? 91.0,
      );
}

class LiveBrewTableModel {
  final String id;
  final String tableNumber;
  final String staticAddressCode;
  final String livebrewUrl;
  final String deepLinkUrl;
  final String? activeBrewSessionId;
  final int qrScansCount;

  const LiveBrewTableModel({
    required this.id,
    required this.tableNumber,
    required this.staticAddressCode,
    required this.livebrewUrl,
    required this.deepLinkUrl,
    this.activeBrewSessionId,
    this.qrScansCount = 0,
  });

  factory LiveBrewTableModel.fromJson(Map<String, dynamic> j) {
    final code = j['static_address_code']?.toString() ?? '7104928374615';
    return LiveBrewTableModel(
      id: j['id']?.toString() ?? '',
      tableNumber: j['table_number']?.toString() ?? 'Meja 01',
      staticAddressCode: code,
      livebrewUrl: j['livebrew_url']?.toString() ?? 'https://coffeelabs.app/livebrew/$code',
      deepLinkUrl: j['deep_link_url']?.toString() ?? 'coffeelabs://livebrew/$code',
      activeBrewSessionId: j['active_brew_session_id']?.toString(),
      qrScansCount: (j['qr_scans_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class LiveBrewSnapshotModel {
  final String sessionId;
  final String dynamicAddressCode;
  final String livebrewUrl;
  final String deepLinkUrl;
  final String? tableNumber;
  final String? staticAddressCode;
  final String storeName;
  final String baristaDisplayName;
  final String customerDisplayName;
  final String recipeTitle;
  final String brewMethod;
  final String beanName;
  final String roasteryName;
  final String beanOrigin;
  final String beanProcess;
  final List<String> tastingNotes;
  final double targetDoseG;
  final double targetWaterMl;
  final double targetTempC;
  final double? secondaryTempC;
  final int targetDurationSec;
  final LiveBrewStage currentStage;
  final int currentStepIndex;
  final int elapsedSec;
  final double currentWeightG;
  final double currentFlowRateMlS;
  final double currentTempC;
  final bool isVideoStreamActive;
  final int cheersReactionsCount;
  final double? finalAccuracyScorePct;
  final List<LiveBrewCurvePoint> catchupCurvePoints;

  const LiveBrewSnapshotModel({
    required this.sessionId,
    required this.dynamicAddressCode,
    required this.livebrewUrl,
    required this.deepLinkUrl,
    this.tableNumber,
    this.staticAddressCode,
    required this.storeName,
    required this.baristaDisplayName,
    required this.customerDisplayName,
    required this.recipeTitle,
    required this.brewMethod,
    required this.beanName,
    required this.roasteryName,
    required this.beanOrigin,
    required this.beanProcess,
    required this.tastingNotes,
    required this.targetDoseG,
    required this.targetWaterMl,
    required this.targetTempC,
    this.secondaryTempC,
    required this.targetDurationSec,
    required this.currentStage,
    required this.currentStepIndex,
    required this.elapsedSec,
    required this.currentWeightG,
    required this.currentFlowRateMlS,
    required this.currentTempC,
    this.isVideoStreamActive = false,
    this.cheersReactionsCount = 0,
    this.finalAccuracyScorePct,
    this.catchupCurvePoints = const [],
  });

  factory LiveBrewSnapshotModel.fromJson(Map<String, dynamic> j) {
    final code = j['dynamic_address_code']?.toString() ?? '3201923849204';
    return LiveBrewSnapshotModel(
      sessionId: j['session_id']?.toString() ?? '',
      dynamicAddressCode: code,
      livebrewUrl: j['livebrew_url']?.toString() ?? 'https://coffeelabs.app/livebrew/$code',
      deepLinkUrl: j['deep_link_url']?.toString() ?? 'coffeelabs://livebrew/$code',
      tableNumber: j['table_number']?.toString(),
      staticAddressCode: j['static_address_code']?.toString(),
      storeName: j['store_name']?.toString() ?? 'Coffee Labs Slow Bar',
      baristaDisplayName: j['barista_display_name']?.toString() ?? 'Barista Coffee Labs',
      customerDisplayName: j['customer_display_name']?.toString() ?? 'Pelanggan Spesial',
      recipeTitle: j['recipe_title']?.toString() ?? 'V60 Live Brew',
      brewMethod: j['brew_method']?.toString() ?? 'V60',
      beanName: j['bean_name']?.toString() ?? 'Malabar Wine Reserve',
      roasteryName: j['roastery_name']?.toString() ?? 'Coffee Labs Roastery',
      beanOrigin: j['bean_origin']?.toString() ?? 'Jawa Barat',
      beanProcess: j['bean_process']?.toString() ?? 'Wine Natural',
      tastingNotes: (j['tasting_notes'] as List? ?? []).map((e) => e.toString()).toList(),
      targetDoseG: (j['target_dose_g'] as num?)?.toDouble() ?? 15.0,
      targetWaterMl: (j['target_water_ml'] as num?)?.toDouble() ?? 225.0,
      targetTempC: (j['target_temp_c'] as num?)?.toDouble() ?? 91.0,
      secondaryTempC: (j['secondary_temp_c'] as num?)?.toDouble(),
      targetDurationSec: (j['target_duration_sec'] as num?)?.toInt() ?? 145,
      currentStage: LiveBrewStage.fromApi(j['current_stage']?.toString()),
      currentStepIndex: (j['current_step_index'] as num?)?.toInt() ?? 0,
      elapsedSec: (j['elapsed_sec'] as num?)?.toInt() ?? 0,
      currentWeightG: (j['current_weight_g'] as num?)?.toDouble() ?? 0.0,
      currentFlowRateMlS: (j['current_flow_rate_ml_s'] as num?)?.toDouble() ?? 0.0,
      currentTempC: (j['current_temp_c'] as num?)?.toDouble() ?? 91.0,
      isVideoStreamActive: j['is_video_stream_active'] == true,
      cheersReactionsCount: (j['cheers_reactions_count'] as num?)?.toInt() ?? 0,
      finalAccuracyScorePct: (j['final_accuracy_score_pct'] as num?)?.toDouble(),
      catchupCurvePoints: (j['catchup_curve_points'] as List? ?? [])
          .map((e) => LiveBrewCurvePoint.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

/// Filter EWMA turunan laju tuang (alpha = 0.28) sesuai Modul 2.2 Bagian 3.
class EwmaFlowFilter {
  static const double alpha = 0.28;
  double _prevFlow = 0.0;
  double? _prevWeight;
  int? _prevMs;

  double update(double weightG, int elapsedMs) {
    if (_prevWeight == null || _prevMs == null || elapsedMs <= _prevMs!) {
      _prevWeight = weightG;
      _prevMs = elapsedMs;
      return _prevFlow;
    }
    final dt = (elapsedMs - _prevMs!) / 1000.0;
    final raw = math.max(0.0, (weightG - _prevWeight!) / math.max(dt, 0.02));
    _prevFlow = alpha * raw + (1.0 - alpha) * _prevFlow;
    _prevWeight = weightG;
    _prevMs = elapsedMs;
    return double.parse(_prevFlow.toStringAsFixed(2));
  }

  void reset() {
    _prevFlow = 0.0;
    _prevWeight = null;
    _prevMs = null;
  }
}

/// Interpolasi Cubic Hermite Spline 10Hz -> 60fps.
double interpolateCubicHermiteWeight(
  LiveBrewCurvePoint p0,
  LiveBrewCurvePoint p1,
  double uNormalized,
) {
  final u = uNormalized.clamp(0.0, 1.0);
  final u2 = u * u;
  final u3 = u2 * u;
  final dt = math.max(0.05, (p1.tMs - p0.tMs) / 1000.0);
  final w = (2 * u3 - 3 * u2 + 1) * p0.wG +
      (u3 - 2 * u2 + u) * dt * p0.flow +
      (-2 * u3 + 3 * u2) * p1.wG +
      (u3 - u2) * dt * p1.flow;
  return math.max(0.0, w);
}
