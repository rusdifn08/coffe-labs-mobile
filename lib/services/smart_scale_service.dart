import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/smart_scale_model.dart';

/// Bluetooth 5.2 Smart Scale Driver for Coffee Labs.
///
/// Works strictly with real Bluetooth LE coffee scales:
/// - TIMEMORE Black Mirror Dot / Nano / Basic / 2
/// - Coffee Labs Scale C3 (Native BLE 5.2 protocol, hardware coming soon)
/// - Acaia Pearl / Lunar / Pyxis
/// - Felicita Arc / Incline & Bookoo Themis
/// - Generic BLE SIG Weight Scale (`0x181D` / `0xFFE0`)
class SmartScaleService extends ChangeNotifier {
  static final SmartScaleService instance = SmartScaleService._internal();

  SmartScaleService._internal() {
    _initBluetooth();
  }

  // Bluetooth State
  bool _isBluetoothSupported = true;
  bool _isBluetoothOn = true;
  bool _isScanning = false;
  String? _lastStatusMessage;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _commandCharacteristic;
  StreamSubscription? _scanSub;
  StreamSubscription? _notifySub;
  StreamSubscription? _connectionSub;

  // Active Device Info
  SmartScaleDevice? _activeScaleDevice;
  final List<SmartScaleDevice> _discoveredDevices = [];

  // Active Brew Mode & Linked Recipe (shared between SmartScaleScreen & BrewTimerScreen)
  ScaleBrewMode _brewMode = ScaleBrewMode.pourOver;
  Map<String, dynamic>? _activeRecipe;

  // Tare & Readings
  double _rawWeight = 0.0;
  double _tareOffset = 0.0;
  double _currentWeight = 0.0;
  double _flowRate = 0.0;
  bool _isStable = true;
  int? _batteryLevel;
  int? _scaleTimerSeconds;

  // Flow rate calculation window (1.2s sliding window with exponential smoothing)
  final List<MapEntry<DateTime, double>> _weightHistory = [];

  // Auto-features
  bool _autoStartTimerOnPour = true;
  bool _hasTriggeredAutoStart = false;
  VoidCallback? onAutoStartBrewTimer;

  // Getters
  bool get isBluetoothSupported => _isBluetoothSupported;
  bool get isBluetoothOn => _isBluetoothOn;
  bool get isScanning => _isScanning;
  bool get isConnected => _activeScaleDevice != null;
  String? get lastStatusMessage => _lastStatusMessage;
  SmartScaleDevice? get activeDevice => _activeScaleDevice;
  List<SmartScaleDevice> get discoveredDevices =>
      List.unmodifiable(_discoveredDevices);

  ScaleBrewMode get brewMode => _brewMode;
  Map<String, dynamic>? get activeRecipe => _activeRecipe;

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

  void setBrewMode(ScaleBrewMode mode) {
    if (_brewMode == mode) return;
    _brewMode = mode;
    notifyListeners();
  }

  void setActiveRecipe(Map<String, dynamic>? recipe) {
    _activeRecipe = recipe == null ? null : Map<String, dynamic>.from(recipe);
    if (recipe != null) {
      final method =
          '${recipe['method'] ?? ''} ${recipe['category'] ?? ''}'.toLowerCase();
      if (method.contains('espresso') || method.contains('ristretto')) {
        _brewMode = ScaleBrewMode.espresso;
      } else {
        _brewMode = ScaleBrewMode.pourOver;
      }
    }
    notifyListeners();
  }

  void _initBluetooth() {
    if (kIsWeb ||
        (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) ||
        Platform.environment.containsKey('FLUTTER_TEST')) {
      _isBluetoothSupported = false;
      _isBluetoothOn = false;
      return;
    }

    try {
      FlutterBluePlus.adapterState.listen(
        (state) {
          _isBluetoothOn = state == BluetoothAdapterState.on;
          if (!_isBluetoothOn && _connectedDevice != null) {
            disconnect();
          }
          notifyListeners();
        },
        onError: (Object e) {
          debugPrint('Bluetooth stream notice: $e');
          _isBluetoothSupported = false;
          _isBluetoothOn = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Bluetooth initialization notice: $e');
      _isBluetoothSupported = false;
      _isBluetoothOn = false;
    }
  }

  // ==========================================
  // SCANNING FOR REAL BLUETOOTH 5.2 SCALES
  // ==========================================
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isScanning) return;

    _discoveredDevices.clear();
    _lastStatusMessage = null;

    if (kIsWeb ||
        (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) ||
        Platform.environment.containsKey('FLUTTER_TEST')) {
      _isBluetoothSupported = false;
      _isScanning = false;
      _lastStatusMessage =
          'Bluetooth LE hanya aktif di perangkat Android / iOS.';
      notifyListeners();
      return;
    }

    _isScanning = true;
    notifyListeners();

    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        _isBluetoothSupported = false;
        _isScanning = false;
        _lastStatusMessage = 'Perangkat ini tidak mendukung Bluetooth LE.';
        notifyListeners();
        return;
      }

      final adapterState = await FlutterBluePlus.adapterState.first.timeout(
        const Duration(seconds: 2),
        onTimeout: () => BluetoothAdapterState.unknown,
      );
      if (adapterState != BluetoothAdapterState.on) {
        _isBluetoothOn = false;
        _isScanning = false;
        _lastStatusMessage =
            'Aktifkan Bluetooth di ponsel Anda untuk memindai TIMEMORE Dot atau Coffee Labs Scale C3.';
        notifyListeners();
        return;
      }
      _isBluetoothOn = true;

      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );

      _scanSub?.cancel();
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : r.advertisementData.advName;
          final uuids = r.advertisementData.serviceUuids;
          final brand = detectBrand(name, uuids);

          if (brand != ScaleBrand.generic || isLikelyScale(name, uuids)) {
            final deviceId = r.device.remoteId.str;
            final existingIndex =
                _discoveredDevices.indexWhere((d) => d.id == deviceId);
            final shortId = deviceId.length >= 5
                ? deviceId.substring(deviceId.length - 5)
                : deviceId;
            final device = SmartScaleDevice(
              id: deviceId,
              name: name.isNotEmpty ? name : 'BLE Smart Scale ($shortId)',
              rssi: r.rssi,
              brand: brand,
            );

            if (existingIndex >= 0) {
              _discoveredDevices[existingIndex] = device;
            } else {
              _discoveredDevices.add(device);
            }
            // Sort strongest RSSI first
            _discoveredDevices.sort((a, b) => b.rssi.compareTo(a.rssi));
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
      _lastStatusMessage =
          'Gagal memindai Bluetooth. Pastikan izin Bluetooth & Lokasi aktif.';
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

  @visibleForTesting
  static bool isLikelyScale(String name, List<Guid> serviceUuids) {
    final lower = name.toLowerCase();
    if (lower.contains('scale') ||
        lower.contains('coffee') ||
        lower.contains('timer') ||
        lower.contains('weigh') ||
        lower.contains('timbang') ||
        lower.contains('black') ||
        lower.contains('mirror') ||
        lower.contains('dot') ||
        lower.contains('nano') ||
        lower.contains('themis') ||
        lower.contains('bookoo') ||
        lower.contains('c3')) {
      return true;
    }
    for (final uuid in serviceUuids) {
      final str = uuid.str.toLowerCase();
      if (str.contains('181d') ||
          str.contains('ffe0') ||
          str.contains('1820') ||
          str.contains('ff00') ||
          str.contains('c0ffee')) {
        return true;
      }
    }
    return false;
  }

  @visibleForTesting
  static ScaleBrand detectBrand(String name, List<Guid> serviceUuids) {
    final lower = name.toLowerCase();
    if (lower.contains('coffee labs') ||
        lower.contains('coffeelabs') ||
        lower.contains('scale c3') ||
        lower.contains('cl-scale') ||
        lower.contains('cl_c3')) {
      return ScaleBrand.coffeeLabsC3;
    }
    for (final uuid in serviceUuids) {
      if (uuid.str.toLowerCase().contains('c0ffee')) {
        return ScaleBrand.coffeeLabsC3;
      }
    }
    if (lower.contains('timemore') ||
        lower.contains('black mirror') ||
        lower.contains('dot scale') ||
        lower.contains('tm_') ||
        lower.contains('bm_')) {
      return ScaleBrand.timemore;
    }
    if (lower.contains('acaia') ||
        lower.contains('lunar') ||
        lower.contains('pearl') ||
        lower.contains('cinco') ||
        lower.contains('pyxis')) {
      return ScaleBrand.acaia;
    }
    if (lower.contains('felicita') ||
        lower.contains('arc') ||
        lower.contains('incline') ||
        lower.contains('parallel')) {
      return ScaleBrand.felicita;
    }
    if (lower.contains('bookoo') || lower.contains('themis')) {
      return ScaleBrand.bookoo;
    }
    return ScaleBrand.generic;
  }

  // ==========================================
  // CONNECTION MANAGEMENT
  // ==========================================
  Future<bool> connect(SmartScaleDevice device) async {
    await stopScan();
    _lastStatusMessage = null;

    try {
      final bluetoothDevice = BluetoothDevice.fromId(device.id);
      await bluetoothDevice.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 10),
      );
      _connectedDevice = bluetoothDevice;

      _connectionSub?.cancel();
      _connectionSub = bluetoothDevice.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected &&
            _activeScaleDevice?.id == device.id) {
          _clearActiveConnectionState();
          _lastStatusMessage = 'Koneksi ke ${device.name} terputus.';
          notifyListeners();
        }
      });

      final services = await bluetoothDevice.discoverServices();
      BluetoothCharacteristic? notifyChar;
      BluetoothCharacteristic? writeChar;

      for (final service in services) {
        final sUuid = service.uuid.str.toLowerCase();
        final isPriorityService = sUuid.contains('181d') ||
            sUuid.contains('ffe0') ||
            sUuid.contains('ff00') ||
            sUuid.contains('1820') ||
            sUuid.contains('c0ffee');
        for (final char in service.characteristics) {
          if ((char.properties.notify || char.properties.indicate) &&
              (notifyChar == null || isPriorityService)) {
            notifyChar = char;
          }
          if ((char.properties.write ||
                  char.properties.writeWithoutResponse) &&
              (writeChar == null || isPriorityService)) {
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

        _activeScaleDevice = device.copyWith(isConnected: true);
        _hasTriggeredAutoStart = false;
        notifyListeners();
        return true;
      } else {
        await bluetoothDevice.disconnect();
        _lastStatusMessage =
            'Karakteristik berat BLE tidak ditemukan pada ${device.name}.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Failed to connect to scale: $e');
      _lastStatusMessage =
          'Gagal terhubung ke ${device.name}. Pastikan timbangan menyala & tidak terhubung ke aplikasi lain.';
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    _notifySub?.cancel();
    _notifySub = null;
    _connectionSub?.cancel();
    _connectionSub = null;

    if (_connectedDevice != null) {
      try {
        await _connectedDevice?.disconnect();
      } catch (_) {}
      _connectedDevice = null;
    }

    _clearActiveConnectionState();
    notifyListeners();
  }

  void _clearActiveConnectionState() {
    _commandCharacteristic = null;
    _activeScaleDevice = null;
    _currentWeight = 0.0;
    _rawWeight = 0.0;
    _tareOffset = 0.0;
    _flowRate = 0.0;
    _isStable = true;
    _batteryLevel = null;
    _scaleTimerSeconds = null;
    _weightHistory.clear();
    _hasTriggeredAutoStart = false;
  }

  /// Legacy no-op retained so `SmartScaleRepository` stays source-compatible
  /// without injecting any fake virtual device into user scans.
  void setSimulatedFlowRate(double gramsPerSec) {}

  // ==========================================
  // PROTOCOL PARSING (TIMEMORE, C3, ACAIA, FELICITA, BOOKOO, SIG)
  // ==========================================
  @visibleForTesting
  static double? parseRawWeightBytes(List<int> bytes, ScaleBrand brand) {
    if (bytes.isEmpty) return null;

    // 1. Coffee Labs Scale C3 Native BLE 5.2 Protocol (Header 0xC3 0x01)
    // Frame: [0xC3, 0x01, flags(bit0=neg, bit1=stable), weightHi, weightMid, weightLo, battery, timerHi, timerLo]
    if (brand == ScaleBrand.coffeeLabsC3 &&
        bytes.length >= 6 &&
        bytes[0] == 0xC3 &&
        bytes[1] == 0x01) {
      final sign = (bytes[2] & 0x01) == 1 ? -1.0 : 1.0;
      final tenths = (bytes[3] << 16) | (bytes[4] << 8) | bytes[5];
      return sign * (tenths / 10.0);
    }

    // 2. TIMEMORE Protocol (Black Mirror Dot / Nano / Basic / 2)
    // Variant A: 0xAA 0x55 frame (Black Mirror 2 / Dot extended telemetry)
    if (bytes.length >= 10 && bytes[0] == 0xAA && bytes[1] == 0x55) {
      final sign = bytes[6] == 1 ? -1.0 : 1.0;
      final rawVal = (bytes[7] << 8) | bytes[8];
      return sign * (rawVal / 10.0);
    }
    // Variant B: 0x02 compact 7+ byte frame (Timemore Dot / Basic / Nano)
    if ((brand == ScaleBrand.timemore || bytes[0] == 0x02) &&
        bytes.length >= 7) {
      final sign = bytes[1] == 1 ? -1.0 : 1.0;
      final rawVal = (bytes[2] << 8) | bytes[3];
      return sign * (rawVal / 10.0);
    }

    // 3. Acaia Protocol (Header 0xEF 0xDD)
    if ((brand == ScaleBrand.acaia ||
            (bytes.length >= 6 && bytes[0] == 0xEF && bytes[1] == 0xDD)) &&
        bytes.length >= 7 &&
        bytes[2] == 0x08) {
      final rawVal = (bytes[4] << 8) | bytes[5];
      final unit = bytes[6];
      return rawVal / (unit == 1 ? 10.0 : 100.0);
    }

    // 4. Bookoo Themis Mini Protocol (Header 0x03 0x0B, 20 bytes)
    if ((brand == ScaleBrand.bookoo ||
            (bytes.length >= 10 && bytes[0] == 0x03 && bytes[1] == 0x0B)) &&
        bytes.length >= 10) {
      final sign = bytes[6] == 0x2D ? -1.0 : 1.0; // '-' ASCII
      final hundredths = (bytes[7] << 16) | (bytes[8] << 8) | bytes[9];
      return sign * (hundredths / 100.0);
    }

    // 5. Felicita ASCII Protocol (Header 0x01 0x02, weight digits in ASCII)
    if (brand == ScaleBrand.felicita && bytes.length >= 9 && bytes[0] == 0x01) {
      final sign = bytes[2] == 0x2D ? -1.0 : 1.0;
      final digits = String.fromCharCodes(bytes.sublist(3, 9)).trim();
      final parsed = double.tryParse(digits);
      if (parsed != null) return sign * (parsed / 100.0);
    }

    // 6. Generic Bluetooth SIG Weight Measurement (0x2A9D)
    if (bytes.length >= 3) {
      final rawVal = (bytes[1] << 8) | bytes[2];
      return rawVal / 10.0;
    }

    return null;
  }

  void _processScaleBytes(List<int> bytes, ScaleBrand brand) {
    if (bytes.isEmpty) return;

    try {
      // Optional battery & timer extraction for Coffee Labs Scale C3
      if (brand == ScaleBrand.coffeeLabsC3 &&
          bytes.length >= 9 &&
          bytes[0] == 0xC3 &&
          bytes[1] == 0x01) {
        _batteryLevel = bytes[6].clamp(0, 100);
        _scaleTimerSeconds = (bytes[7] << 8) | bytes[8];
      }

      final weight = parseRawWeightBytes(bytes, brand);
      if (weight != null && weight >= -500.0 && weight <= 5000.0) {
        _rawWeight = weight;
        _updateCalculatedWeight(_rawWeight);
      }
    } catch (e) {
      debugPrint('Scale payload parse error: $e');
    }
  }

  void _updateCalculatedWeight(double raw, {DateTime? sampleTime}) {
    final net = math.max(-100.0, raw - _tareOffset);
    _currentWeight = (net * 10).round() / 10.0; // 0.1g precision

    final now = sampleTime ?? DateTime.now();
    _weightHistory.add(MapEntry(now, _currentWeight));

    // Keep sliding window to 1.2 seconds for responsive & smooth g/s flow rate
    _weightHistory.removeWhere((e) => now.difference(e.key).inMilliseconds > 1200);

    if (_weightHistory.length >= 2) {
      final first = _weightHistory.first;
      final last = _weightHistory.last;
      final deltaSec = last.key.difference(first.key).inMilliseconds / 1000.0;
      if (deltaSec > 0.18) {
        final deltaWeight = last.value - first.value;
        final rawRate = deltaWeight / deltaSec;
        final smoothed = (_flowRate * 0.65) + (rawRate * 0.35);
        _flowRate = (math.max(0.0, smoothed) * 10).round() / 10.0;
      }
    } else {
      _flowRate = 0.0;
    }

    _isStable = _flowRate < 0.2;

    // Auto-trigger brew timer start on first detected pour / espresso drop
    final double minWeightTrigger =
        _brewMode == ScaleBrewMode.espresso ? 0.5 : 1.5;
    final double minFlowTrigger =
        _brewMode == ScaleBrewMode.espresso ? 0.2 : 0.5;
    if (_autoStartTimerOnPour &&
        !_hasTriggeredAutoStart &&
        _flowRate >= minFlowTrigger &&
        _currentWeight >= minWeightTrigger) {
      _hasTriggeredAutoStart = true;
      onAutoStartBrewTimer?.call();
    }

    notifyListeners();
  }

  // ==========================================
  // HARDWARE COMMANDS (Tare, Timer Start/Stop/Reset)
  // ==========================================
  Future<void> tare() async {
    _tareOffset = _rawWeight;
    _currentWeight = 0.0;
    _flowRate = 0.0;
    _weightHistory.clear();
    _hasTriggeredAutoStart = false;

    if (_commandCharacteristic != null) {
      try {
        switch (_activeScaleDevice?.brand) {
          case ScaleBrand.coffeeLabsC3:
            await _commandCharacteristic!
                .write([0xC3, 0x02, 0x01, 0x00], withoutResponse: true);
            break;
          case ScaleBrand.timemore:
            await _commandCharacteristic!
                .write([0x02, 0x01, 0x00, 0x00, 0x03], withoutResponse: true);
            break;
          case ScaleBrand.acaia:
            await _commandCharacteristic!.write(
              [0xEF, 0xDD, 0x04, 0x00, 0x00, 0x00],
              withoutResponse: true,
            );
            break;
          case ScaleBrand.felicita:
            await _commandCharacteristic!
                .write([0x54], withoutResponse: true); // 'T'
            break;
          case ScaleBrand.bookoo:
            await _commandCharacteristic!.write(
              [0x03, 0x0A, 0x01, 0x00, 0x00, 0x08],
              withoutResponse: true,
            );
            break;
          default:
            break;
        }
      } catch (e) {
        debugPrint('Tare write command notice: $e');
      }
    }

    notifyListeners();
  }

  Future<void> sendStartTimerCommand() async {
    if (_commandCharacteristic == null) return;
    try {
      switch (_activeScaleDevice?.brand) {
        case ScaleBrand.coffeeLabsC3:
          await _commandCharacteristic!
              .write([0xC3, 0x02, 0x02, 0x01], withoutResponse: true);
          break;
        case ScaleBrand.timemore:
          await _commandCharacteristic!
              .write([0x02, 0x02, 0x01, 0x00, 0x03], withoutResponse: true);
          break;
        case ScaleBrand.bookoo:
          await _commandCharacteristic!.write(
            [0x03, 0x0A, 0x04, 0x00, 0x00, 0x0D],
            withoutResponse: true,
          );
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('Timer start command notice: $e');
    }
  }

  Future<void> sendStopTimerCommand() async {
    if (_commandCharacteristic == null) return;
    try {
      switch (_activeScaleDevice?.brand) {
        case ScaleBrand.coffeeLabsC3:
          await _commandCharacteristic!
              .write([0xC3, 0x02, 0x02, 0x00], withoutResponse: true);
          break;
        case ScaleBrand.timemore:
          await _commandCharacteristic!
              .write([0x02, 0x02, 0x00, 0x00, 0x03], withoutResponse: true);
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('Timer stop command notice: $e');
    }
  }

  void resetAutoStartTrigger() {
    _hasTriggeredAutoStart = false;
  }

  // ==========================================
  // TEST-ONLY HOOKS (Never exposed in production UI)
  // ==========================================
  @visibleForTesting
  void debugAttachTestDevice(SmartScaleDevice device, {int? batteryPercent}) {
    _activeScaleDevice = device.copyWith(isConnected: true);
    _batteryLevel = batteryPercent;
    _hasTriggeredAutoStart = false;
    notifyListeners();
  }

  @visibleForTesting
  void debugFeedRawBytes(List<int> bytes, {DateTime? sampleTime}) {
    final brand = _activeScaleDevice?.brand ?? ScaleBrand.timemore;
    final parsed = parseRawWeightBytes(bytes, brand);
    if (brand == ScaleBrand.coffeeLabsC3 &&
        bytes.length >= 9 &&
        bytes[0] == 0xC3 &&
        bytes[1] == 0x01) {
      _batteryLevel = bytes[6].clamp(0, 100);
      _scaleTimerSeconds = (bytes[7] << 8) | bytes[8];
    }
    if (parsed != null) {
      _rawWeight = parsed;
      _updateCalculatedWeight(_rawWeight, sampleTime: sampleTime);
    }
  }

  @visibleForTesting
  void debugResetForTest() {
    _discoveredDevices.clear();
    _activeRecipe = null;
    _brewMode = ScaleBrewMode.pourOver;
    _lastStatusMessage = null;
    _clearActiveConnectionState();
    notifyListeners();
  }
}
