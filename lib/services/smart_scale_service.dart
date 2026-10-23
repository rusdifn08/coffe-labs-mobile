import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/smart_scale_model.dart';

class SmartScaleService extends ChangeNotifier {
  static final SmartScaleService instance = SmartScaleService._internal();

  SmartScaleService._internal() {
    _initBluetooth();
  }

  // Bluetooth State
  bool _isBluetoothSupported = true;
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _commandCharacteristic;
  StreamSubscription? _scanSub;
  StreamSubscription? _notifySub;

  // Active Device Info
  SmartScaleDevice? _activeScaleDevice;
  final List<SmartScaleDevice> _discoveredDevices = [];

  // Tare & Readings
  double _rawWeight = 0.0;
  double _tareOffset = 0.0;
  double _currentWeight = 0.0;
  double _flowRate = 0.0;
  bool _isStable = true;
  final int _batteryLevel = 100;
  final int _scaleTimerSeconds = 0;

  // Flow rate calculation window
  final List<MapEntry<DateTime, double>> _weightHistory = [];

  // Simulator
  bool _isSimulationMode = false;
  Timer? _simulationTimer;
  double _simulatedPourSpeed = 0.0; // g/s

  // Auto-features
  bool _autoStartTimerOnPour = true;
  bool _hasTriggeredAutoStart = false;
  VoidCallback? onAutoStartBrewTimer;

  // Getters
  bool get isBluetoothSupported => _isBluetoothSupported;
  bool get isScanning => _isScanning;
  bool get isConnected => _activeScaleDevice != null;
  bool get isSimulationMode => _isSimulationMode;
  SmartScaleDevice? get activeDevice => _activeScaleDevice;
  List<SmartScaleDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);

  double get currentWeight => _currentWeight;
  double get flowRate => _flowRate;
  bool get isStable => _isStable;
  int? get batteryLevel => _batteryLevel;
  int? get scaleTimerSeconds => _scaleTimerSeconds;
  bool get autoStartTimerOnPour => _autoStartTimerOnPour;

  void setAutoStartTimerOnPour(bool value) {
    _autoStartTimerOnPour = value;
    notifyListeners();
  }

  void _initBluetooth() {
    try {
      FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          if (_connectedDevice != null && !_isSimulationMode) {
            disconnect();
          }
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Bluetooth initialization notice: $e');
      _isBluetoothSupported = false;
    }
  }

  // ==========================================
  // SCANNING FOR COFFEE SCALES
  // ==========================================
  Future<void> startScan({Duration timeout = const Duration(seconds: 8)}) async {
    if (_isScanning) return;

    _discoveredDevices.clear();
    // Always provide simulated scale option for instant zero-hardware testing
    _discoveredDevices.add(const SmartScaleDevice(
      id: 'SIMULATED_SCALE',
      name: 'Coffee Labs Virtual Smart Scale',
      rssi: -42,
      brand: ScaleBrand.simulated,
    ));
    _isScanning = true;
    notifyListeners();

    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        _isBluetoothSupported = false;
        _isScanning = false;
        notifyListeners();
        return;
      }

      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );

      _scanSub?.cancel();
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          final name = r.device.platformName.isNotEmpty ? r.device.platformName : r.advertisementData.advName;
          final brand = _detectBrand(name, r.advertisementData.serviceUuids);

          // Filter coffee scales or standard scales
          if (brand != ScaleBrand.generic || _isLikelyScale(name, r.advertisementData.serviceUuids)) {
            final deviceId = r.device.remoteId.str;
            final existingIndex = _discoveredDevices.indexWhere((d) => d.id == deviceId);
            final device = SmartScaleDevice(
              id: deviceId,
              name: name.isNotEmpty ? name : 'BLE Smart Scale (${r.device.remoteId.str.substring(0, 5)})',
              rssi: r.rssi,
              brand: brand,
            );

            if (existingIndex >= 0) {
              _discoveredDevices[existingIndex] = device;
            } else {
              _discoveredDevices.add(device);
            }
            notifyListeners();
          }
        }
      });

      Future.delayed(timeout, () {
        stopScan();
      });
    } catch (e) {
      debugPrint('Error starting Bluetooth scan: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    _scanSub?.cancel();
    _isScanning = false;
    notifyListeners();
  }

  bool _isLikelyScale(String name, List<Guid> serviceUuids) {
    final lower = name.toLowerCase();
    if (lower.contains('scale') ||
        lower.contains('coffee') ||
        lower.contains('timer') ||
        lower.contains('weigh') ||
        lower.contains('timbang') ||
        lower.contains('black') ||
        lower.contains('mirror') ||
        lower.contains('dot')) {
      return true;
    }
    for (final uuid in serviceUuids) {
      final str = uuid.str.toLowerCase();
      if (str.contains('181d') || str.contains('ffe0') || str.contains('1820')) {
        return true;
      }
    }
    return false;
  }

  ScaleBrand _detectBrand(String name, List<Guid> serviceUuids) {
    final lower = name.toLowerCase();
    if (lower.contains('timemore') || lower.contains('black mirror') || lower.contains('dot scale') || lower.contains('bm_')) {
      return ScaleBrand.timemore;
    }
    if (lower.contains('acaia') || lower.contains('lunar') || lower.contains('pearl') || lower.contains('cinco')) {
      return ScaleBrand.acaia;
    }
    if (lower.contains('felicita') || lower.contains('arc') || lower.contains('incline')) {
      return ScaleBrand.felicita;
    }
    return ScaleBrand.generic;
  }

  // ==========================================
  // CONNECTION MANAGEMENT
  // ==========================================
  Future<bool> connect(SmartScaleDevice device) async {
    await stopScan();

    if (device.brand == ScaleBrand.simulated) {
      _enableSimulationMode();
      return true;
    }

    try {
      final bluetoothDevice = BluetoothDevice.fromId(device.id);
      await bluetoothDevice.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 10),
      );
      _connectedDevice = bluetoothDevice;

      // Discover Services
      final services = await bluetoothDevice.discoverServices();
      BluetoothCharacteristic? notifyChar;
      BluetoothCharacteristic? writeChar;

      for (final service in services) {
        for (final char in service.characteristics) {
          if (char.properties.notify || char.properties.indicate) {
            notifyChar = char;
          }
          if (char.properties.write || char.properties.writeWithoutResponse) {
            writeChar = char;
          }
        }
      }

      if (notifyChar != null) {
        _commandCharacteristic = writeChar;
        await notifyChar.setNotifyValue(true);
        _notifySub?.cancel();
        _notifySub = notifyChar.lastValueStream.listen((data) {
          _processScaleBytes(data, device.brand);
        });

        _isSimulationMode = false;
        _activeScaleDevice = device.copyWith(isConnected: true);
        notifyListeners();
        return true;
      } else {
        await bluetoothDevice.disconnect();
        return false;
      }
    } catch (e) {
      debugPrint('Failed to connect to scale: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _isSimulationMode = false;

    _notifySub?.cancel();
    _notifySub = null;

    if (_connectedDevice != null) {
      try {
        await _connectedDevice?.disconnect();
      } catch (_) {}
      _connectedDevice = null;
    }

    _activeScaleDevice = null;
    _currentWeight = 0.0;
    _rawWeight = 0.0;
    _tareOffset = 0.0;
    _flowRate = 0.0;
    _hasTriggeredAutoStart = false;
    notifyListeners();
  }

  // ==========================================
  // SIMULATION / VIRTUAL SCALE ENGINE
  // ==========================================
  void _enableSimulationMode() {
    _isSimulationMode = true;
    _activeScaleDevice = const SmartScaleDevice(
      id: 'SIMULATED_SCALE',
      name: 'Coffee Labs Virtual Smart Scale',
      rssi: -45,
      brand: ScaleBrand.simulated,
      isConnected: true,
    );
    _rawWeight = 0.0;
    _tareOffset = 0.0;
    _currentWeight = 0.0;
    _flowRate = 0.0;
    _isStable = true;
    _hasTriggeredAutoStart = false;

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_simulatedPourSpeed > 0.0) {
        // Add water with slight realistic noise (+- 0.05g)
        final noise = (math.Random().nextDouble() - 0.5) * 0.1;
        _rawWeight += (_simulatedPourSpeed * 0.1) + noise;
        if (_rawWeight < 0.0) _rawWeight = 0.0;
      }
      _updateCalculatedWeight(_rawWeight);
    });

    notifyListeners();
  }

  /// Simulate adding dry coffee beans (e.g. 15.0g or 18.5g)
  void simulateAddCoffee(double grams) {
    if (!_isSimulationMode) return;
    _rawWeight += grams;
    _updateCalculatedWeight(_rawWeight);
    notifyListeners();
  }

  /// Start pouring water with given flow rate (g/s)
  void setSimulatedFlowRate(double gramsPerSec) {
    _simulatedPourSpeed = math.max(0.0, gramsPerSec);
    notifyListeners();
  }

  // ==========================================
  // DATA PARSING (Timemore, Acaia, Felicita, SIG)
  // ==========================================
  void _processScaleBytes(List<int> bytes, ScaleBrand brand) {
    if (bytes.isEmpty) return;

    try {
      double weight = 0.0;

      // 1. Timemore Protocol (typically starts with 0x02 or 0xAA)
      if (brand == ScaleBrand.timemore || (bytes.length >= 7 && bytes[0] == 0x02)) {
        if (bytes.length >= 7) {
          final sign = bytes[1] == 1 ? -1 : 1;
          final high = bytes[2];
          final low = bytes[3];
          weight = sign * ((high << 8) | low) / 10.0;
        } else if (bytes.length >= 10 && bytes[0] == 0xAA && bytes[1] == 0x55) {
          final sign = bytes[6] == 1 ? -1 : 1;
          final rawVal = (bytes[7] << 8) | bytes[8];
          weight = sign * (rawVal / 10.0);
        }
      }
      // 2. Acaia Protocol (Header 0xEF 0xDD)
      else if (brand == ScaleBrand.acaia || (bytes.length >= 6 && bytes[0] == 0xEF && bytes[1] == 0xDD)) {
        if (bytes.length >= 7 && bytes[2] == 0x08) {
          final rawVal = (bytes[4] << 8) | bytes[5];
          final unit = bytes[6]; // 1: grams, 2: oz
          weight = rawVal / (unit == 1 ? 10.0 : 100.0);
        }
      }
      // 3. Generic Bluetooth SIG Weight (0x2A9D)
      else if (bytes.length >= 3) {
        final rawVal = (bytes[1] << 8) | bytes[2];
        weight = rawVal / 10.0;
      }

      if (weight >= -500.0 && weight <= 5000.0) {
        _rawWeight = weight;
        _updateCalculatedWeight(_rawWeight);
      }
    } catch (e) {
      debugPrint('Scale payload parse error: $e');
    }
  }

  void _updateCalculatedWeight(double raw) {
    final net = math.max(-100.0, raw - _tareOffset);
    _currentWeight = (net * 10).round() / 10.0; // 0.1g precision

    final now = DateTime.now();
    _weightHistory.add(MapEntry(now, _currentWeight));

    // Keep history window to 1.2 seconds for smooth flow rate calculation
    _weightHistory.removeWhere((e) => now.difference(e.key).inMilliseconds > 1200);

    if (_weightHistory.length >= 2) {
      final first = _weightHistory.first;
      final last = _weightHistory.last;
      final deltaSec = last.key.difference(first.key).inMilliseconds / 1000.0;
      if (deltaSec > 0.2) {
        final deltaWeight = last.value - first.value;
        final rawRate = deltaWeight / deltaSec;
        // Low-pass filter for stable flow rate reading
        _flowRate = math.max(0.0, ((_flowRate * 0.7) + (rawRate * 0.3)));
        _flowRate = (math.max(0.0, _flowRate) * 10).round() / 10.0;
      }
    } else {
      _flowRate = 0.0;
    }

    _isStable = _flowRate < 0.2;

    // Auto-trigger brew timer start if first pour is detected
    if (_autoStartTimerOnPour && !_hasTriggeredAutoStart && _flowRate >= 0.5 && _currentWeight >= 2.0) {
      _hasTriggeredAutoStart = true;
      onAutoStartBrewTimer?.call();
    }

    notifyListeners();
  }

  // ==========================================
  // SCALE COMMANDS (Tare, Reset, Zero)
  // ==========================================
  Future<void> tare() async {
    _tareOffset = _rawWeight;
    _currentWeight = 0.0;
    _flowRate = 0.0;
    _weightHistory.clear();
    _hasTriggeredAutoStart = false;

    // Send Tare command packet to physical scale if connected
    if (_commandCharacteristic != null) {
      try {
        if (_activeScaleDevice?.brand == ScaleBrand.timemore) {
          // Timemore tare packet
          await _commandCharacteristic!.write([0x02, 0x01, 0x00, 0x00, 0x03], withoutResponse: true);
        } else if (_activeScaleDevice?.brand == ScaleBrand.acaia) {
          // Acaia tare packet
          await _commandCharacteristic!.write([0xEF, 0xDD, 0x04, 0x00, 0x00, 0x00], withoutResponse: true);
        }
      } catch (e) {
        debugPrint('Tare write command notice: $e');
      }
    }

    notifyListeners();
  }

  void resetAutoStartTrigger() {
    _hasTriggeredAutoStart = false;
  }
}
