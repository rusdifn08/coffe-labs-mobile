import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/smart_scale_model.dart';
import '../services/smart_scale_service.dart';

part 'smart_scale_repository.g.dart';

/// Kontrak Repositori Timbangan Kopi Pintar (Bluetooth Smart Scale & Simulasi).
abstract class SmartScaleRepository {
  bool get isConnected;
  bool get isScanning;
  double get currentWeight;
  double get flowRate;
  SmartScaleDevice? get activeDevice;
  List<SmartScaleDevice> get discoveredDevices;

  Future<void> startScan();
  Future<void> stopScan();
  Future<bool> connect(SmartScaleDevice device);
  Future<void> disconnect();
  Future<void> tare();
  void setSimulationFlow(double gramsPerSec);
}

/// Implementasi SmartScaleRepository mendelegasikan ke driver SmartScaleService.
class SmartScaleRepositoryImpl implements SmartScaleRepository {
  final SmartScaleService _service;

  SmartScaleRepositoryImpl({SmartScaleService? service})
      : _service = service ?? SmartScaleService.instance;

  @override
  bool get isConnected => _service.isConnected;

  @override
  bool get isScanning => _service.isScanning;

  @override
  double get currentWeight => _service.currentWeight;

  @override
  double get flowRate => _service.flowRate;

  @override
  SmartScaleDevice? get activeDevice => _service.activeDevice;

  @override
  List<SmartScaleDevice> get discoveredDevices => _service.discoveredDevices;

  @override
  Future<void> startScan() => _service.startScan();

  @override
  Future<void> stopScan() => _service.stopScan();

  @override
  Future<bool> connect(SmartScaleDevice device) => _service.connect(device);

  @override
  Future<void> disconnect() => _service.disconnect();

  @override
  Future<void> tare() => _service.tare();

  @override
  void setSimulationFlow(double gramsPerSec) => _service.setSimulatedFlowRate(gramsPerSec);
}

/// Provider Dependency Injection untuk [SmartScaleRepository].
@riverpod
SmartScaleRepository smartScaleRepository(Ref ref) {
  return SmartScaleRepositoryImpl();
}
