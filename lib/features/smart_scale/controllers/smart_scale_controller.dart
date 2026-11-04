import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../models/smart_scale_model.dart';
import '../../../repositories/smart_scale_repository.dart';

part 'smart_scale_controller.freezed.dart';
part 'smart_scale_controller.g.dart';

/// State snapshot timbangan digital pintar menggunakan Freezed.
@freezed
abstract class SmartScaleState with _$SmartScaleState {
  const factory SmartScaleState({
    @Default(false) bool isConnected,
    @Default(false) bool isScanning,
    @Default(0.0) double currentWeight,
    @Default(0.0) double flowRate,
    SmartScaleDevice? activeDevice,
    @Default(<SmartScaleDevice>[]) List<SmartScaleDevice> discoveredDevices,
  }) = _SmartScaleState;
}

/// Notifier untuk mengontrol koneksi timbangan Bluetooth dan pembacaan massa real-time.
@riverpod
class SmartScaleController extends _$SmartScaleController {
  @override
  SmartScaleState build() {
    final repo = ref.watch(smartScaleRepositoryProvider);
    return SmartScaleState(
      isConnected: repo.isConnected,
      isScanning: repo.isScanning,
      currentWeight: repo.currentWeight,
      flowRate: repo.flowRate,
      activeDevice: repo.activeDevice,
      discoveredDevices: repo.discoveredDevices,
    );
  }

  Future<void> startScan() async {
    final repo = ref.read(smartScaleRepositoryProvider);
    state = state.copyWith(isScanning: true);
    await repo.startScan();
    state = state.copyWith(
      isScanning: repo.isScanning,
      discoveredDevices: repo.discoveredDevices,
    );
  }

  Future<void> stopScan() async {
    final repo = ref.read(smartScaleRepositoryProvider);
    await repo.stopScan();
    state = state.copyWith(isScanning: false);
  }

  Future<bool> connect(SmartScaleDevice device) async {
    final repo = ref.read(smartScaleRepositoryProvider);
    final ok = await repo.connect(device);
    state = state.copyWith(
      isConnected: ok,
      activeDevice: repo.activeDevice,
    );
    return ok;
  }

  Future<void> disconnect() async {
    final repo = ref.read(smartScaleRepositoryProvider);
    await repo.disconnect();
    state = state.copyWith(
      isConnected: false,
      activeDevice: null,
      currentWeight: 0.0,
      flowRate: 0.0,
    );
  }

  Future<void> tare() async {
    final repo = ref.read(smartScaleRepositoryProvider);
    await repo.tare();
    state = state.copyWith(currentWeight: 0.0);
  }

  void toggleSimulation(bool enable) {
    final repo = ref.read(smartScaleRepositoryProvider);
    repo.setSimulationFlow(enable ? 3.0 : 0.0);
  }
}
