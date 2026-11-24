import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/smart_scale/services/scale_brew_history_service.dart';
import '../features/smart_scale/widgets/extraction_chart_painter.dart';
import '../features/smart_scale/widgets/scale_device_sheet.dart';
import '../features/smart_scale/widgets/scale_device_status_banner.dart';
import '../features/smart_scale/widgets/scale_flow_rate_gauge.dart';
import '../features/smart_scale/widgets/scale_history_tab.dart';
import '../features/smart_scale/widgets/scale_ratio_calculator_card.dart';
import '../features/smart_scale/widgets/scale_recipe_coach_tab.dart';
import '../models/smart_scale_model.dart';
import '../services/language_service.dart';
import '../services/smart_scale_service.dart';
import '../theme/app_theme.dart';
import 'brew_timer_screen.dart';

/// Coffee Labs Smart Scale Studio (TIMEMORE Black Mirror Dot-class experience).
///
/// Built in Coffee Labs' warm bright palette (`AppTheme.bgCream`, `Colors.white`,
/// `AppTheme.primaryBrown`) with real Bluetooth 5.2 connectivity for TIMEMORE Dot,
/// Coffee Labs Scale C3 (upcoming), Acaia, Felicita, Bookoo & BLE SIG scales.
class SmartScaleScreen extends ConsumerStatefulWidget {
  const SmartScaleScreen({super.key});

  @override
  ConsumerState<SmartScaleScreen> createState() => _SmartScaleScreenState();
}

class _SmartScaleScreenState extends ConsumerState<SmartScaleScreen>
    with SingleTickerProviderStateMixin {
  final SmartScaleService _scaleService = SmartScaleService.instance;
  late final TabController _tabController;

  // Live Brew Timer & Telemetry Curve
  Timer? _ticker;
  int _brewTicks = 0; // 200ms per tick => 5 Hz curve recording
  bool _isTimerRunning = false;
  final List<WeightDataPoint> _dataPoints = [];
  double _peakFlowRate = 0.0;
  double _flowSum = 0.0;
  int _flowSamples = 0;

  // Brew Mode & Ratio Config
  ScaleBrewMode _mode = ScaleBrewMode.pourOver;
  double _coffeeDoseGrams = 15.0;
  double _selectedRatio = 15.0;
  bool _isOunces = false;

  // Active Recipe & Target Ghost Curve
  Map<String, dynamic>? _activeRecipe;
  List<WeightDataPoint> _targetCurve = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _mode = _scaleService.brewMode;
    _activeRecipe = _scaleService.activeRecipe;
    if (_activeRecipe != null) {
      _applyRecipeFields(_activeRecipe!);
    }

    _scaleService.addListener(_onScaleUpdate);
    _scaleService.onAutoStartBrewTimer = _startTimerAutomatically;
    ScaleBrewHistoryService.loadLogs();

    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!_isTimerRunning || !_scaleService.isConnected) return;
      final flow = _scaleService.flowRate;
      final weight = _scaleService.currentWeight;
      setState(() {
        _brewTicks++;
        if (flow > _peakFlowRate) _peakFlowRate = flow;
        if (flow > 0.05) {
          _flowSum += flow;
          _flowSamples++;
        }
        _dataPoints.add(
          WeightDataPoint(
            elapsedSeconds: _brewTicks * 0.2,
            weight: weight,
            flowRate: flow,
          ),
        );
        // Up to 1500 samples (5 minutes at 5 Hz)
        if (_dataPoints.length > 1500) {
          _dataPoints.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _tabController.dispose();
    _scaleService.removeListener(_onScaleUpdate);
    _scaleService.onAutoStartBrewTimer = null;
    super.dispose();
  }

  void _onScaleUpdate() {
    if (mounted) setState(() {});
  }

  void _startTimerAutomatically() {
    if (!_scaleService.isConnected) return;
    if (!_isTimerRunning) {
      setState(() => _isTimerRunning = true);
    }
  }

  void _selectMode(ScaleBrewMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _scaleService.setBrewMode(mode);
      if (_activeRecipe == null) {
        _coffeeDoseGrams = mode.defaultDoseGrams;
        _selectedRatio = mode.defaultRatio;
      }
    });
  }

  void _applyRecipeFields(Map<String, dynamic> recipe) {
    final dose = (recipe['coffeeWeightGrams'] as num?)?.toDouble() ?? 15.0;
    final water =
        (recipe['totalWaterWeightGrams'] as num?)?.toDouble() ?? 225.0;
    final method =
        '${recipe['method'] ?? ''} ${recipe['category'] ?? ''}'.toLowerCase();
    final isEsp = method.contains('espresso') || method.contains('ristretto');
    _mode = isEsp ? ScaleBrewMode.espresso : ScaleBrewMode.pourOver;
    _coffeeDoseGrams = dose.clamp(5.0, 60.0);
    _selectedRatio =
        dose > 0 ? double.parse((water / dose).toStringAsFixed(1)) : 15.0;
    _targetCurve = ScaleRecipeCoachTab.buildTargetCurve(recipe);
  }

  void _onSelectRecipeForScale(Map<String, dynamic> recipe) {
    setState(() {
      _activeRecipe = Map<String, dynamic>.from(recipe);
      _scaleService.setActiveRecipe(_activeRecipe);
      _applyRecipeFields(_activeRecipe!);
      _resetTimer();
    });
    _tabController.animateTo(0);
  }

  void _clearActiveRecipe() {
    setState(() {
      _activeRecipe = null;
      _targetCurve = const [];
      _scaleService.setActiveRecipe(null);
    });
  }

  void _openBrewTimer(Map<String, dynamic> recipe) {
    _scaleService.setActiveRecipe(recipe);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrewTimerScreen(recipeData: recipe),
      ),
    );
  }

  void _toggleTimer() {
    if (!_scaleService.isConnected) {
      ScaleDeviceSheet.show(context, _scaleService);
      return;
    }
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
    if (_isTimerRunning) {
      _scaleService.sendStartTimerCommand();
    } else {
      _scaleService.sendStopTimerCommand();
    }
  }

  void _resetTimer() {
    setState(() {
      _isTimerRunning = false;
      _brewTicks = 0;
      _dataPoints.clear();
      _peakFlowRate = 0.0;
      _flowSum = 0.0;
      _flowSamples = 0;
      _scaleService.resetAutoStartTrigger();
    });
  }

  Future<void> _saveCurrentBrewSession(bool isEn) async {
    final totalSec = (_brewTicks * 0.2).round();
    final finalWeight = _scaleService.currentWeight;

    if (!_scaleService.isConnected || (totalSec < 3 && finalWeight < 1.0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.primaryBrown,
          content: Text(
            isEn
                ? 'Connect your Bluetooth scale and record a brew first before saving.'
                : 'Hubungkan timbangan Bluetooth dan rekam sesi seduhan terlebih dahulu.',
          ),
        ),
      );
      return;
    }

    final avgFlow = _flowSamples > 0
        ? _flowSum / _flowSamples
        : (totalSec > 0 ? finalWeight / totalSec : 0.0);

    final log = ScaleBrewLog(
      id: 'scale_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      mode: _mode,
      recipeTitle: _activeRecipe?['title']?.toString() ??
          '${_mode.label(isEn: isEn)} ${_coffeeDoseGrams.toStringAsFixed(0)}g (1:${_selectedRatio.toStringAsFixed(1)})',
      methodName: _activeRecipe?['method']?.toString() ??
          _mode.label(isEn: isEn),
      deviceName: _scaleService.activeDevice?.name ?? 'Bluetooth Smart Scale',
      coffeeDoseGrams: _coffeeDoseGrams,
      targetWaterGrams: _mode == ScaleBrewMode.general
          ? finalWeight
          : (_coffeeDoseGrams * _selectedRatio),
      finalWeightGrams: finalWeight,
      durationSeconds: totalSec,
      avgFlowRate: double.parse(avgFlow.toStringAsFixed(2)),
      peakFlowRate: double.parse(_peakFlowRate.toStringAsFixed(2)),
      points: List<WeightDataPoint>.from(_dataPoints),
    );

    await ScaleBrewHistoryService.saveLog(log);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F766E),
        content: Text(
          isEn
              ? 'Brew curve saved to History! Ready to share with the community.'
              : 'Kurva seduhan disimpan ke Riwayat! Siap dibagikan ke komunitas.',
        ),
        action: SnackBarAction(
          label: isEn ? 'View' : 'Lihat',
          textColor: Colors.white,
          onPressed: () => _tabController.animateTo(2),
        ),
      ),
    );
  }

  String _formatTimer(int ticks) {
    final totalSec = (ticks * 0.2).floor();
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _displayWeight(double grams) {
    if (_isOunces) {
      return (grams * 0.035274).toStringAsFixed(2);
    }
    return grams.toStringAsFixed(1);
  }

  /// Resolves current Coffee Coach pour step based on elapsed time.
  Map<String, dynamic>? _resolveActiveCoachStep() {
    final steps = _activeRecipe?['steps'];
    if (steps is! List || steps.isEmpty) return null;
    final elapsedSec = (_brewTicks * 0.2).floor();
    int accTime = 0;
    double accWeight = 0;

    for (int i = 0; i < steps.length; i++) {
      final raw = steps[i];
      if (raw is! Map) continue;
      final dur = ((raw['durationSeconds'] ?? raw['timeSeconds']) as num?)
              ?.toInt() ??
          30;
      final addWater = ((raw['waterAddedGrams'] ?? raw['waterGrams']) as num?)
              ?.toDouble() ??
          0.0;
      accTime += dur;
      accWeight += addWater;
      if (elapsedSec < accTime || i == steps.length - 1) {
        return {
          'index': i + 1,
          'total': steps.length,
          'title': (raw['title'] ?? 'Tahap ${i + 1}').toString(),
          'instruction': (raw['instruction'] ?? '').toString(),
          'targetWeight': accWeight,
          'endSec': accTime,
        };
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.isEnglish;
    final isConnected = _scaleService.isConnected;
    final currentDevice = _scaleService.activeDevice;
    final weight = isConnected ? _scaleService.currentWeight : 0.0;
    final flowRate = isConnected ? _scaleService.flowRate : 0.0;
    final isStable = _scaleService.isStable;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const Icon(
              CupertinoIcons.gauge,
              color: AppTheme.primaryBrown,
              size: 19,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                isEn ? 'Smart Scale' : 'Smart Scale',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Compact Unit Toggle (g / oz)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              onTap: () => setState(() => _isOunces = !_isOunces),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: Text(
                  _isOunces ? 'OZ' : 'GRAM',
                  style: const TextStyle(
                    color: AppTheme.primaryBrown,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Bluetooth Connection Action
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => ScaleDeviceSheet.show(context, _scaleService),
              borderRadius: BorderRadius.circular(11),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isConnected
                      ? const Color(0xFF0F766E).withValues(alpha: 0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isConnected
                        ? const Color(0xFF0F766E).withValues(alpha: 0.4)
                        : AppTheme.borderWarm,
                  ),
                ),
                child: Icon(
                  isConnected
                      ? CupertinoIcons.bluetooth
                      : CupertinoIcons.bolt_slash_fill,
                  size: 18,
                  color: isConnected
                      ? const Color(0xFF0F766E)
                      : AppTheme.primaryBrown,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryBrown,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textMuted,
                labelStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(text: isEn ? 'Scale' : 'Timbangan'),
                  Tab(text: isEn ? 'Recipes' : 'Resep & Coach'),
                  Tab(text: isEn ? 'History' : 'Riwayat'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveScaleTab(
            isEn: isEn,
            isConnected: isConnected,
            currentDevice: currentDevice,
            weight: weight,
            flowRate: flowRate,
            isStable: isStable,
          ),
          ScaleRecipeCoachTab(
            isEn: isEn,
            activeRecipe: _activeRecipe,
            onSelectForScale: _onSelectRecipeForScale,
            onOpenBrewTimer: _openBrewTimer,
          ),
          ScaleHistoryTab(isEn: isEn),
        ],
      ),
    );
  }

  Widget _buildLiveScaleTab({
    required bool isEn,
    required bool isConnected,
    required SmartScaleDevice? currentDevice,
    required double weight,
    required double flowRate,
    required bool isStable,
  }) {
    final targetWater = _coffeeDoseGrams * _selectedRatio;
    final liveRatio = _coffeeDoseGrams > 0 ? weight / _coffeeDoseGrams : 0.0;
    final yieldPercent =
        targetWater > 0 ? ((weight / targetWater) * 100).clamp(0.0, 150.0) : 0.0;
    final avgFlow = _flowSamples > 0
        ? _flowSum / _flowSamples
        : (_brewTicks > 5 ? weight / (_brewTicks * 0.2) : 0.0);
    final coachStep = _resolveActiveCoachStep();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Brew Mode Selector (Pour-Over / Espresso / General)
          _buildModeSwitcher(isEn),
          const SizedBox(height: 10),

          // 2. BLE 5.2 Connection Banner
          ScaleDeviceStatusBanner(
            isEn: isEn,
            isConnected: isConnected,
            currentDevice: currentDevice,
            batteryLevel: _scaleService.batteryLevel,
            onOpenSheet: () => ScaleDeviceSheet.show(context, _scaleService),
          ),
          const SizedBox(height: 10),

          // 3. Active Coffee Coach Banner (when recipe selected)
          if (_activeRecipe != null && coachStep != null) ...[
            _buildCoffeeCoachBanner(
              isEn: isEn,
              coachStep: coachStep,
              currentWeight: weight,
            ),
            const SizedBox(height: 10),
          ],

          // 4. Precision 0.1g Digital Readout & Telemetry Card
          _buildTelemetryDisplayCard(
            isEn: isEn,
            isConnected: isConnected,
            weight: weight,
            flowRate: flowRate,
            isStable: isStable,
            liveRatio: liveRatio,
            yieldPercent: yieldPercent,
          ),
          const SizedBox(height: 12),

          // 5. Primary Hardware Controls (TARE / Start-Pause / Reset / Save)
          _buildControlRow(isEn: isEn, isConnected: isConnected),
          const SizedBox(height: 12),

          // 6. Dual-Curve Extraction Graph (Water Weight + Flow Rate + Recipe Ghost)
          _buildExtractionGraphCard(
            isEn: isEn,
            isConnected: isConnected,
            avgFlow: avgFlow,
            targetWater: targetWater,
          ),
          const SizedBox(height: 12),

          // 7. Live Flow Rate Meter
          ScaleFlowRateGauge(
            flowRate: flowRate,
            mode: _mode,
            isEn: isEn,
          ),

          // 8. Dose & Target Ratio Calculator (Pour-Over & Espresso)
          if (_mode != ScaleBrewMode.general) ...[
            const SizedBox(height: 12),
            ScaleRatioCalculatorCard(
              isEn: isEn,
              mode: _mode,
              coffeeDoseGrams: _coffeeDoseGrams,
              selectedRatio: _selectedRatio,
              currentWeight: weight,
              onDoseChanged: (d) => setState(() => _coffeeDoseGrams = d),
              onRatioChanged: (r) => setState(() => _selectedRatio = r),
            ),
          ],

          const SizedBox(height: 14),

          // 9. Guided Brewing Time Bridge Card
          _buildBrewTimerBridgeCard(isEn),
        ],
      ),
    );
  }

  Widget _buildModeSwitcher(bool isEn) {
    return Row(
      children: ScaleBrewMode.values.map((m) {
        final active = _mode == m;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: m == ScaleBrewMode.values.last ? 0 : 6,
            ),
            child: InkWell(
              onTap: () => _selectMode(m),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
                decoration: BoxDecoration(
                  color: active ? AppTheme.primaryBrown : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active ? AppTheme.primaryBrown : AppTheme.borderWarm,
                  ),
                ),
                child: Text(
                  m.label(isEn: isEn),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: active ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCoffeeCoachBanner({
    required bool isEn,
    required Map<String, dynamic> coachStep,
    required double currentWeight,
  }) {
    final targetStepWeight = (coachStep['targetWeight'] as double?) ?? 0.0;
    final remaining = math.max(0.0, targetStepWeight - currentWeight);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentAmber.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.sparkles,
                size: 15,
                color: Color(0xFFB45309),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${_activeRecipe!['title']}  •  ${coachStep['index']}/${coachStep['total']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
              InkWell(
                onTap: _clearActiveRecipe,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${coachStep['title']} — Target ${targetStepWeight.toStringAsFixed(0)} g (${isEn ? 'Remaining' : 'Sisa'} ${remaining.toStringAsFixed(1)} g)',
            style: const TextStyle(
              fontSize: 12.2,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          if ((coachStep['instruction'] as String).isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              coachStep['instruction'] as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelemetryDisplayCard({
    required bool isEn,
    required bool isConnected,
    required double weight,
    required double flowRate,
    required bool isStable,
    required double liveRatio,
    required double yieldPercent,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isConnected
              ? AppTheme.primaryBrown.withValues(alpha: 0.28)
              : AppTheme.borderWarm,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Status Row (Stability + Auto-Timer Toggle)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: !isConnected
                      ? AppTheme.bgCream
                      : (isStable
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFF7ED)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: !isConnected
                            ? AppTheme.textMuted
                            : (isStable
                                ? const Color(0xFF0F766E)
                                : const Color(0xFFD97706)),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      !isConnected
                          ? (isEn ? 'STANDBY BLE' : 'MENUNGGU BLE')
                          : (isStable
                              ? (isEn ? 'STABLE 0.1g' : 'STABIL 0.1g')
                              : (isEn ? 'POURING' : 'MENUANG')),
                      style: TextStyle(
                        fontSize: 9.8,
                        fontWeight: FontWeight.w800,
                        color: !isConnected
                            ? AppTheme.textMuted
                            : (isStable
                                ? const Color(0xFF0F766E)
                                : const Color(0xFFC2410C)),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _scaleService
                    .setAutoStartTimerOnPour(!_scaleService.autoStartTimerOnPour),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _scaleService.autoStartTimerOnPour
                        ? AppTheme.accentAmber.withValues(alpha: 0.16)
                        : AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.bolt_fill,
                        size: 12,
                        color: _scaleService.autoStartTimerOnPour
                            ? AppTheme.primaryBrown
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _scaleService.autoStartTimerOnPour
                            ? (isEn ? 'AUTO-TIMER ON' : 'AUTO-TIMER')
                            : (isEn ? 'MANUAL TIMER' : 'MANUAL'),
                        style: TextStyle(
                          fontSize: 9.8,
                          fontWeight: FontWeight.w800,
                          color: _scaleService.autoStartTimerOnPour
                              ? AppTheme.primaryBrown
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main 0.1g Precision Weight Readout
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                isConnected ? _displayWeight(weight) : '--.-',
                style: TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  color: isConnected ? AppTheme.textDark : AppTheme.textMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 5),
              Text(
                _isOunces ? 'oz' : 'g',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBrown,
                ),
              ),
            ],
          ),

          if (!isConnected) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.bluetooth,
                    size: 14,
                    color: AppTheme.primaryBrown,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isEn
                          ? 'Connect TIMEMORE Dot or Coffee Labs Scale C3 for real-time 0.1g telemetry'
                          : 'Hubungkan TIMEMORE Dot atau Coffee Labs Scale C3 untuk pembacaan real-time 0.1g',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10.8,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // 3-Column Live Telemetry Strip: Timer | Flow Rate | Ratio/Yield
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgCream,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderWarm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _telemetryMetric(
                    label: isEn ? 'BREW TIME' : 'WAKTU',
                    value: _formatTimer(_brewTicks),
                    valueColor: AppTheme.textDark,
                  ),
                ),
                Container(width: 1, height: 28, color: AppTheme.dividerColor),
                Expanded(
                  child: _telemetryMetric(
                    label: isEn ? 'FLOW RATE' : 'DEBIT AIR',
                    value: isConnected
                        ? '${flowRate.toStringAsFixed(1)} g/s'
                        : '0.0 g/s',
                    valueColor: const Color(0xFF0F766E),
                  ),
                ),
                Container(width: 1, height: 28, color: AppTheme.dividerColor),
                Expanded(
                  child: _telemetryMetric(
                    label: _mode == ScaleBrewMode.general
                        ? (isEn ? 'UNIT' : 'SATUAN')
                        : (isEn ? 'RATIO / YIELD' : 'RASIO / YIELD'),
                    value: _mode == ScaleBrewMode.general
                        ? (_isOunces ? 'Ounce' : 'Gram')
                        : '1:${liveRatio.toStringAsFixed(1)} (${yieldPercent.round()}%)',
                    valueColor: AppTheme.primaryBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _telemetryMetric({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: valueColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildControlRow({
    required bool isEn,
    required bool isConnected,
  }) {
    return Row(
      children: [
        // TARE
        Expanded(
          child: _actionButton(
            icon: CupertinoIcons.arrow_2_circlepath,
            label: isEn ? 'TARE' : 'NOL-KAN',
            bgColor: Colors.white,
            fgColor: AppTheme.primaryBrown,
            borderColor: AppTheme.borderWarm,
            onTap: () {
              if (!isConnected) {
                ScaleDeviceSheet.show(context, _scaleService);
                return;
              }
              _scaleService.tare();
            },
          ),
        ),
        const SizedBox(width: 8),
        // START / PAUSE
        Expanded(
          flex: 2,
          child: _actionButton(
            icon: _isTimerRunning
                ? CupertinoIcons.pause_fill
                : CupertinoIcons.play_fill,
            label: !isConnected
                ? (isEn ? 'Connect Scale' : 'Hubungkan Scale')
                : (_isTimerRunning
                    ? (isEn ? 'Pause' : 'Jeda')
                    : (isEn ? 'Start Brew' : 'Mulai Seduh')),
            bgColor: _isTimerRunning
                ? const Color(0xFFD97706)
                : AppTheme.primaryBrown,
            fgColor: Colors.white,
            borderColor: Colors.transparent,
            onTap: _toggleTimer,
          ),
        ),
        const SizedBox(width: 8),
        // RESET
        SizedBox(
          width: 48,
          child: _actionButton(
            icon: CupertinoIcons.arrow_clockwise,
            label: '',
            bgColor: Colors.white,
            fgColor: AppTheme.textDark,
            borderColor: AppTheme.borderWarm,
            onTap: _resetTimer,
          ),
        ),
        const SizedBox(width: 8),
        // SAVE CURVE
        SizedBox(
          width: 48,
          child: _actionButton(
            icon: CupertinoIcons.checkmark_seal_fill,
            label: '',
            bgColor: const Color(0xFFECFDF5),
            fgColor: const Color(0xFF0F766E),
            borderColor: const Color(0xFF0F766E).withValues(alpha: 0.35),
            onTap: () => _saveCurrentBrewSession(isEn),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color fgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fgColor),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: fgColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExtractionGraphCard({
    required bool isEn,
    required bool isConnected,
    required double avgFlow,
    required double targetWater,
  }) {
    final targetSec =
        (_activeRecipe?['totalTimeSeconds'] as num?)?.toDouble() ??
            (_mode == ScaleBrewMode.espresso ? 35.0 : 180.0);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart_rounded,
                size: 17,
                color: AppTheme.primaryBrown,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isEn
                      ? 'Extraction & Flow Curve'
                      : 'Grafik Kurva Air, Debit & Yield',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _legendItem(
                AppTheme.primaryBrown,
                isEn ? 'Weight / Yield (g)' : 'Berat / Yield (g)',
              ),
              _legendItem(
                const Color(0xFF0F766E),
                isEn ? 'Flow Rate (g/s)' : 'Debit Air (g/s)',
              ),
              if (_targetCurve.isNotEmpty)
                _legendItem(
                  const Color(0xFFD97706),
                  isEn ? 'Recipe Target' : 'Target Resep',
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 155,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            decoration: BoxDecoration(
              color: AppTheme.bgCream,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppTheme.borderWarm),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: ExtractionChartPainter(
                      dataPoints: _dataPoints,
                      targetCurve: _targetCurve,
                      targetMaxWeight: targetWater,
                      targetMaxSeconds: targetSec,
                      maxFlowScale: _mode == ScaleBrewMode.espresso ? 4.0 : 9.0,
                    ),
                  ),
                ),
                if (_dataPoints.isEmpty && _targetCurve.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        isConnected
                            ? (isEn
                                ? 'Start pouring or press Start Brew to plot real-time weight & flow rate.'
                                : 'Mulai menuang atau tekan Mulai Seduh untuk merekam grafik berat & debit air.')
                            : (isEn
                                ? 'Live curve activates automatically once a Bluetooth 5.2 scale is connected.'
                                : 'Grafik kurva aktif otomatis setelah timbangan Bluetooth 5.2 terhubung.'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  isEn ? 'Avg Flow' : 'Rata-rata Debit',
                  '${avgFlow.toStringAsFixed(1)} g/s',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniStat(
                  isEn ? 'Peak Flow' : 'Puncak Debit',
                  '${_peakFlowRate.toStringAsFixed(1)} g/s',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniStat(
                  isEn ? 'Samples' : 'Titik Data',
                  '${_dataPoints.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9.5, color: AppTheme.textMuted),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrewTimerBridgeCard(bool isEn) {
    final recipeToLaunch = _activeRecipe ??
        ScaleRecipeCoachTab.builtInCoachRecipes().firstWhere(
          (r) => _mode == ScaleBrewMode.espresso
              ? (r['category'] == 'Espresso')
              : (r['category'] == 'Pour-Over'),
          orElse: () => ScaleRecipeCoachTab.builtInCoachRecipes().first,
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrown.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBrown.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBrown,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.timer,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn
                      ? 'Sync with Guided Brewing Time'
                      : 'Gunakan di Brewing Time Terpandu',
                  style: const TextStyle(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _activeRecipe != null
                      ? '${_activeRecipe!['title']} • Auto-start saat menuang'
                      : (isEn
                          ? 'Pick a recipe or launch Guided Brew Timer with live BLE weight & voice coach.'
                          : 'Pilih resep atau buka Brew Timer dengan pembacaan berat & suara pemandu otomatis.'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.8,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _openBrewTimer(recipeToLaunch),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isEn ? 'Brew' : 'Seduh',
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
